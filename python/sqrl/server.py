import sys
import logging
from StringIO import StringIO
from flask import Flask, request, abort, send_file, session, render_template, redirect, jsonify
from pysodium import *
import base64url
import qrcode
import qrcode.image.svg
import urlparse
from datetime import datetime
import sqlite3
import libsqrl
from collections import namedtuple

app = Flask(__name__)
conn = sqlite3.connect(':memory:', check_same_thread=False)

def create_db():
    c = conn.cursor()
    c.execute("""
        create table sqrl_identity (
            id integer primary key,
            idk text,
            suk text,
            vuk text)
    """)
    c.execute("""
        create table sqrl_session (
            id integer primary key,
            session_id text,
            identity_id integer,
            created_date integer)
    """)
    conn.commit()

sqrl_user = namedtuple('namedtuple', 'identity_id idk suk vuk')

def get_user_by_idk(idk):
    vals = (base64url.encode(idk),)
    c = conn.cursor()
    c.execute("""
        select id, idk, suk, vuk
        from sqrl_identity
        where idk = ?
    """, vals)
    row = c.fetchone()
    return sqrl_user(*row) if row else None

def get_user_by_session(session_id):
    vals = (session_id,)
    c = conn.cursor()
    c.execute("""
        select i.id, i.idk, i.suk, i.vuk
        from sqrl_identity i
        inner join sqrl_session s on s.identity_id = i.id
        where s.session_id = ?
    """, vals)
    row = c.fetchone()
    return sqrl_user(*row) if row else None

def delete_session(session_id):
    vals = (session_id,)
    conn.execute("""
        delete from sqrl_session where session_id = ?
    """, vals)

@app.route('/')
def index():
    try:
        session_id = unicode(session['session_id'])
    except KeyError:
        session_id = base64url.encode(crypto_stream(8L))
        session['session_id'] = session_id
    user = get_user_by_session(session_id)
    if user:
        return render_template('logged_in.html', idk=user.idk)
    else:
        login_url = generate_login_url(session_id)
        qr_code = base64url.encode(login_url)
        return render_template('login.html', login_url=login_url, qr_code=qr_code)

@app.route('/logout')
def logout():
    try:
        session_id = unicode(session['session_id'])
        del session['session_id']
        delete_session(session_id)
    except KeyError:
        pass
    return redirect('/')

@app.route('/loggedin')
def loggedin():
    session_id = 0
    try:
        session_id = unicode(session['session_id'])
    except KeyError:
        pass
    user = get_user_by_session(session_id)
    logged_in = user is not None
    return jsonify(logged_in=logged_in)

def generate_login_url(session_id):
    scheme = 'qrl'
    netloc = 'localhost:5000'
    path = '/sqrl'
    args = dict(session_id=session_id)
    query = '&'.join('{0}={1}'.format(k, v) for k, v in args.iteritems())
    parts = urlparse.ParseResult(scheme=scheme, netloc=netloc, path=path,
        params='', query=query, fragment='')
    return urlparse.urlunparse(parts)

@app.route('/qr')
def qrcode_svg():
    info = urlparse.urlparse(request.url)
    if len(info.query) > 0:
        login_url = base64url.decode(info.query.encode('utf-8'))
        img = qrcode.make(login_url, image_factory=qrcode.image.svg.SvgImage)
        res = StringIO()
        img.save(res)
        res.seek(0)
        return send_file(res, mimetype='image/svg+xml')
    else:
        abort(400)

@app.route('/sqrl', methods=['GET', 'POST'])
def sqrl_endpoint():
    if request.method == 'GET':
        return 'Display endpoint documentation'
    elif request.method == 'POST':
        return handle_sqrl_request()
    else:
        abort(405)

def handle_sqrl_request():
    req = libsqrl.SqrlRequestBody.deserialize(request.data)

    # TODO: Verify signatures
    # TODO: Verify unchanged message contents

    info = urlparse.urlparse(req.server)
    qs = urlparse.parse_qs(info.query)
    session_id = qs['session_id'][0]

    user = get_user_by_idk(req.client.idk)

    tif = libsqrl.TIF.AccountCreationEnabled
    if user:
        tif |= libsqrl.TIF.IdMatch

    # TODO: Update TIF

    if 'setkey' in req.client.cmd:
        abort(505)

    if 'setlock' in req.client.cmd:
        abort(505)

    if 'disable' in req.client.cmd:
        abort(505)

    if 'enable' in req.client.cmd:
        abort(505)

    if 'delete' in req.client.cmd:
        abort(505)

    if 'create' in req.client.cmd:
        c = conn.cursor()
        vals = (base64url.encode(req.client.idk), \
                base64url.encode(req.client.suk), \
                base64url.encode(req.client.vuk))
        c.execute("""
            insert into sqrl_identity (idk, suk, vuk)
            values (?, ?, ?)
        """, vals)
        conn.commit()

    if user and 'login' in req.client.cmd:
        c = conn.cursor()
        vals = (session_id, user.identity_id, datetime.utcnow())
        c.execute("""
            insert into sqrl_session (
                session_id,
                identity_id,
                created_date)
            values (?, ?, ?)
        """, vals)
        conn.commit()

    if 'logme' in req.client.cmd:
        abort(505)

    if 'logoff' in req.client.cmd:
        abort(505)

    # TODO: Attach nut

    res = libsqrl.SqrlResponse()
    res.tif = tif

    if user:
        res.suk = user.suk
        res.vuk = user.vuk

    return res.serialize()

if __name__ == '__main__':
    create_db()
    app.secret_key = 'secret'
    app.run(host='localhost', port=5000, debug=True)
