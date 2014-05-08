import sys
import logging
from StringIO import StringIO
from flask import Flask, request, abort, send_file
from pysodium import *
import base64url
import qrcode
import qrcode.image.svg

app = Flask(__name__)

@app.route('/')
def index():
    login_url = generate_login_url()
    qr_data = base64url.encode(login_url)
    return '<p>Login url:</p><a href="' + login_url + '"><img src="/qr?' + qr_data + '" /></a><p>' + login_url + '</p>'

def generate_login_url():
    return 'qrl://localhost:5000/sqrl?' + base64url.encode(crypto_stream(32L))

@app.route('/qr')
def qrcode_svg():
    if '?' in request.url:
        parts = request.url.split('?')
        qr_data = parts[1].strip()
        login_url = base64url.decode(qr_data)
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
    return request.method, 200

if __name__ == '__main__':
    logger = logging.getLogger()
    handler = logging.StreamHandler(stream=sys.stdout)
    handler.setLevel(logging.DEBUG)
    logger.addHandler(handler)
    app.run(host='localhost', port=5000, debug=True)
