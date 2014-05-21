#!/usr/bin/env python
"""Test sqrl client.

Usage:
  client.py create --identity=<file> [--password=<pw>] [--iterations=<iterations>]
  client.py verify --identity=<file> [--password=<pw>]
  client.py update --identity=<file> [--password=<pw>] --unlock
  client.py update --identity=<file> [--password=<pw>] [--change-password=<newpw>] [--change-iterations=<iterations>]
  client.py login --identity=<file> [--password=<pw>] --url=<url>

Options:
  -h, --help                        Show this screen.
  -V, --version                     Show version.
  --identity=<file>                 Output file.
  --password=<pw>                   [default: ]
  --iterations=<iterations>         Password strength. [default: 1200]
  --change-iterations=<iterations>  Change password strength.
  --change-password=<newpw>         Change password. [default: ]
  --unlock                          Generate identity unlock keys.
  --url=<url>                       SQRL url.

"""
import os
import sys
from pysodium import *
import urlparse
import binascii
from PBKDF import PBKDF2
import test_fileformat as ff
from test_fileformat import SqrlIdentity
import requests
import base64url
import libsqrl

def create_identity(pw, iterations):
    """Return randomly generated identity encrypted with pw.
    This does not include creation of identity unlock keys.
    """
    iterations = max(iterations, 1)
    salt = crypto_stream(SALT_LEN)
    pw_hash = create_pw_hash(pw, salt, iterations)
    pw_verify = create_pw_verify(pw_hash)
    masterkey = xor_masterkey(crypto_stream(IDK_LEN), pw_hash, salt)
    identity = SqrlIdentity(
        masterkey=masterkey,
        salt=salt,
        pw_iterations=iterations,
        pw_verify=pw_verify,
        identity_lock_key=''
    )
    return identity

def verify_password(identity, pw):
    """Return true if pw hash matches identity pw verification hash."""
    pw_hash = create_pw_hash(pw, identity.salt, identity.pw_iterations)
    pw_verify = create_pw_verify(pw_hash)
    return pw_verify == identity.pw_verify

def change_pw(identity, pw, newpw, newiterations):
    newiterations = max(newiterations, 1)

    # Confirm valid password.
    pw_hash = create_pw_hash(pw, identity.salt, identity.pw_iterations)
    pw_verify = create_pw_verify(pw_hash)
    if pw_verify != identity.pw_verify:
        raise Exception('Invalid password.')

    # Decrypt key with old pw.
    original_masterkey = xor_masterkey(identity.masterkey, pw_hash, identity.salt)

    # Encrypt with new pw.
    salt = crypto_stream(SALT_LEN)
    pw_hash = create_pw_hash(newpw, salt, newiterations)
    pw_verify = create_pw_verify(pw_hash)
    masterkey = xor_masterkey(original_masterkey, pw_hash, salt)
    identity.salt = salt
    identity.pw_iterations = newiterations
    identity.pw_verify = pw_verify
    identity.masterkey = masterkey

def save_identity(file, identity):
    with open(file, 'wb') as fs:
        ff.save(fs, identity)

def load_identity(file):
    with open(file, 'rb') as fs:
        return ff.load(fs)

def xor_masterkey(masterkey, pw_hash, salt):
    """Return masterkey XOR pw_hash with salt."""
    return crypto_stream_xor(masterkey, len(masterkey), key=pw_hash, nonce=salt)

def create_pw_hash(pw, salt, iterations):
    return PBKDF2(pw, salt, c=iterations)

def create_pw_verify(pw_hash):
    return crypto_generichash(pw_hash, outlen=PW_VERIFIER_LEN)

def generate_site_keypair(masterkey, domain):
    """Return keypair based on site and master key"""
    seed = crypto_generichash(domain, k=masterkey)
    pk, sk = crypto_sign_seed_keypair(seed)
    return pk, sk

def post_request(payload):
    info = urlparse.urlparse(url)
    if info.scheme not in ['qrl', 'sqrl']:
        raise Exception('Url scheme not supported.')

    headers = {
        'User-Agent': 'SQRL/1'
    }

    if info.scheme == 'sqrl':
        post_url = url.replace('sqrl://', 'https://')
    else:
        post_url = url.replace('qrl://', 'http://')

    r = requests.post(post_url, data=payload, headers=headers)

    if r.status_code != 200:
        raise Exception(r.text)

    return libsqrl.SqrlResponse.deserialize(r.text)

def create_request_body(user, url, cmd=None):
    info = urlparse.urlparse(url)
    host = info.netloc

    pw_hash = create_pw_hash(
        user.pw,
        user.identity.salt,
        user.identity.pw_iterations)

    original_masterkey = xor_masterkey(
        user.identity.masterkey,
        pw_hash,
        user.identity.salt)

    pk, sk = generate_site_keypair(original_masterkey, host)

    req = libsqrl.SqrlRequestBody()
    req.server = url
    req.client.cmd = cmd
    req.client.idk = pk

    clientval = req.client.serialize()
    serverval = base64url.encode(req.server)
    m = clientval + serverval

    req.ids = base64url.encode(crypto_sign(m, sk))
    return req

def fetch_account(user, url):
    payload = create_request_body(user, url)
    response = post_request(payload.serialize())
    return libsqrl.SqrlAccount(user, url, response.suk, response.vuk, response.tif)

def login(account):
    if libsqrl.has_flag(account.tif, libsqrl.TIF.IdMatch):
        payload = create_request_body(user, url, cmd='login')
        response = post_request(payload.serialize())
    else:
        print 'no account registered'

if __name__ == '__main__':
    from docopt import docopt
    args = docopt(__doc__, version='1.0.0')

    # Disable output buffering.
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)

    #print(args)
    #sys.exit(0)

    if args['login']:
        url = args['--url']
        password = args['--password']
        identity = load_identity(args['--identity'])
        user = libsqrl.SqrlUser(identity, password)
        account = fetch_account(user, url)
        login(account)
        sys.exit(0)
    elif args['register']:
        sys.exit(0)
    elif args['create']:
        password = args['--password']
        iterations = int(args['--iterations'])
        identity = create_identity(password, iterations)
        save_identity(args['--identity'], identity)
        sys.exit(0)
    elif args['update']:
        identity = load_identity(args['--identity'])
        if args['--unlock']:
            # Confirm password is valid before making any changes.
            if not verify_password(identity, args['--password']):
                print('Invalid password.')
                sys.exit(1)
            ilk, iuk = crypto_box_keypair()
            identity.identity_lock_key = ilk
            save_identity(args['--identity'], identity)
            print('Here is your identity unlock key. You will need this to make changes to your account later.')
            print('Store this in a safe location!')
            print(binascii.hexlify(iuk))
            sys.exit(0)
        else:
            # We don't need to confirm the password before changing it because the change password
            # function already does that.
            password = args['--password']
            newpassword = args['--change-password']
            newiterations = identity.pw_iterations
            if args['--change-iterations']:
                newiterations = int(args['--change-iterations'])
            change_pw(identity, password, newpassword, newiterations)
            save_identity(args['--identity'], identity)
            sys.exit(0)
    elif args['verify']:
        identity = load_identity(args['--identity'])
        if verify_password(identity, args['--password']):
            sys.exit(0)
        else:
            print('Invalid password.')
            sys.exit(1)
