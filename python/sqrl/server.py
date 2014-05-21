import sys
import logging
from StringIO import StringIO
from flask import Flask, request, abort, send_file, session
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
            vuk text
    )""")
    c.execute("""
        create table sqrl_session (
            id integer primary key,
            session_id text,
            identity_id integer,
            created_date integer
    )
    """)
    conn.commit()

tmpuser = namedtuple('namedtuple', 'suk vuk identity_id')

def get_user_by_idk(idk):
    u = tmpuser('', '', 1)
    return u

def user_logged_in(user):
    return False

def user_enabled(user):
    return True

@app.route('/')
def index():
    if 'session_id' not in session:
        session['session_id'] = crypto_stream(8L)
    session_id = session['session_id']
    login_url = generate_login_url(session_id)
    qr_data = base64url.encode(login_url)
    output = []
    output.append('<p>Login url:</p>')
    output.append('<a href="' + login_url + '"><img src="/qr?' + qr_data + '" /></a>')
    output.append('<p>' + login_url + '</p>')
    return ''.join(output)

def generate_login_url(session_id):
    scheme = 'qrl'
    netloc = 'localhost:5000'
    path = '/sqrl'
    args = dict(
        session_id=base64url.encode(session_id),
        created=str(datetime.utcnow())
    )
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
        if user_logged_in(user):
            tif |= libsqrl.TIF.LoggedIn
        if user_enabled(user):
            tif |= libsqrl.TIF.SqrlEnabled

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
        abort(505)

    if user and 'login' in req.client.cmd:
        c = conn.cursor()
        print session_id, type(session_id)
        vals = (session_id, user.identity_id, datetime.utcnow())
        c.execute("""
            insert into sqrl_session (
                session_id,
                identity_id,
                created_date)
            values (?, ?, ?)
        """, vals)
        conn.commit()

        # Display sessions
        c = conn.cursor()
        q = c.execute("""
            select * from sqrl_session
        """)
        for row in q:
            print row

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
