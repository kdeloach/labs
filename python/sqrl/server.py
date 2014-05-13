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

app = Flask(__name__)
conn = sqlite3.connect(':memory:')

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
    create table sqrl_sessions (
        id integer primary key,
        session_id text,
        identity_id integer
    )
    """)
    conn.commit()
    conn.close()

@app.route('/')
def index():
    if 'session_id' not in session:
        session['session_id'] = crypto_stream(8L)
    session_id = session['session_id']
    login_url = make_login_url(session_id)
    qr_data = base64url.encode(login_url)
    output = []
    output.append('<p>Login url:</p>')
    output.append('<a href="' + login_url + '"><img src="/qr?' + qr_data + '" /></a>')
    output.append('<p>' + login_url + '</p>')
    return ''.join(output)

def make_login_url(session_id):
    scheme = 'qrl'
    netloc = 'localhost:5000'
    path = '/sqrl'
    args = {
        'session_id': base64url.encode(session_id),
        'created': str(datetime.utcnow())
    }
    query = '&'.join('{0}={1}'.format(k, v) for k, v in args.iteritems())
    parts = urlparse.ParseResult(scheme=scheme, netloc=netloc, path=path,
        params='', query=query, fragment='')
    return urlparse.urlunparse(parts)

@app.route('/qr')
def qrcode_svg():
    info = urlparse.urlparse(request.url)
    if len(info.query) > 0:
        login_url = base64url.decode(info.query)
        img = qrcode.make(login_url, image_factory=qrcode.image.svg.SvgImage)
        res = StringIO()
        img.save(res)
        res.seek(0)
        return send_file(res, mimetype='image/svg+xml')
    else:
        abort(400)

@app.route('/sqrl', methods=['GET', 'POST'])
def sqrl_request():
    if request.method == 'GET':
        return 'Display endpoint documentation'
    elif request.method == 'POST':
        return sqrl_post_request()
    else:
        abort(405)

def sqrl_post_request():
    try:
        x = sqrl.parse(request.data)
    except InvalidClient:
        abort(400)

    tif = 0
    row = get_user_by_idk(x.client.idk)

    if 'setkey' in x.client.cmd:
        abort(505)

    if 'setlock' in x.client.cmd:
        abort(505)

    if 'disable' in x.client.cmd:
        abort(505)

    if 'enable' in x.client.cmd:
        abort(505)

    if 'delete' in x.client.cmd:
        abort(505)

    if 'create' in x.client.cmd:
        # insert record for new user
        # insert idk, suk, vuk
        c = conn.cursor()
        c.execute('insert in')
        conn.commit()
        conn.close()

    if 'login' in x.client.cmd:
        # mark nonce as authenticated
        pass

    if 'logme' in x.client.cmd:
        abort(505)

    if 'logoff' in x.client.cmd:
        abort(505)

    # Return SUK, VUK, tif, etc.

    # attach tif
    # attach sfn (server friendly name)
    # attach nut
    # send response

    data = urlparse.parse_qs(request.data)
    if 'client' not in data:
        abort(400)
    if 'server' not in data:
        abort(400)


    print data
    abort(400)
    info = urlparse.urlparse(request.url)
    if len(info.query) > 0:
        print info
        abort(400)
        payload = base64url.decode(info.query)
        print 'payload: ', payload
        return 'payload:' + payload, 200
    else:
        abort(400)

if __name__ == '__main__':
    create_db()
    app.secret_key = 'secret'
    app.run(host='localhost', port=5000, debug=True)
