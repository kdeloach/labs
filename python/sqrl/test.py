from pysodium import *
import urlparse
import binascii
from PBKDF import PBKDF2

def test():
    pw = 'abc123'
    iterations = 1200

    print 'Create password encrypted masterkey'
    masterkey, salt = create_masterkey(pw, iterations)
    print binascii.hexlify(masterkey)

    print 'Change password'
    pw2 = 'xyz456'
    masterkey2, salt2 = change_pw(masterkey, pw, salt, iterations, pw2)
    print binascii.hexlify(masterkey2)

    print 'Masterkey hash should match after password change'
    actual_masterkey = xor_masterkey(masterkey, pw, salt, iterations)
    actual_masterkey2 = xor_masterkey(masterkey2, pw2, salt2, iterations)
    print binascii.hexlify(actual_masterkey)
    print binascii.hexlify(actual_masterkey2)
    assert actual_masterkey == actual_masterkey2

    print 'Change password iterations'
    iterations2 = 2400
    masterkey2 = change_pw_iterations(masterkey, pw, salt, iterations, iterations2)

    print 'Masterkey hash should match after password iterations change'
    actual_masterkey = xor_masterkey(masterkey, pw, salt, iterations)
    actual_masterkey2 = xor_masterkey(masterkey2, pw, salt, iterations2)
    print binascii.hexlify(actual_masterkey)
    print binascii.hexlify(actual_masterkey2)
    assert actual_masterkey == actual_masterkey2

    print 'Simulate scanning a QR code'
    url, nonce = scan_qr_code()

    print 'Parse url'
    urlinfo = urlparse.urlparse(url)

    print 'Generate site-specific keypair'
    pk, sk = generate_site_keypair(actual_masterkey, urlinfo.netloc)
    print binascii.hexlify(sk)
    print binascii.hexlify(pk)

    print 'Sign nonce'
    message = crypto_sign(nonce, sk)
    print binascii.hexlify(message)

    # TODO: Submit signed message to url

    # Check that message was signed with pk
    try:
        crypto_sign_open(message, pk)
        print "Logged in"
    except ValueError:
        print "Failed to verify message was signed with pk"

def create_pwhash(pw, salt, iterations):
    return PBKDF2(pw, salt, c=iterations)

def xor_masterkey(masterkey, pw, salt, iterations):
    """Return masterkey XOR pwhash with salt nonce"""
    pwhash = create_pwhash(pw, salt, iterations)
    return crypto_stream_xor(masterkey, len(masterkey), key=pwhash, nonce=salt)

def create_masterkey(pw, iterations):
    salt = crypto_stream(64L)
    masterkey = crypto_stream(32L)
    masterkey = xor_masterkey(masterkey, pw, salt, iterations)
    return masterkey, salt

def change_pw_iterations(masterkey, pw, salt, olditerations, newiterations):
    """Return masterkey encrypted with new pw hash"""
    # Decrypt key with old pw
    original_masterkey = xor_masterkey(masterkey, pw, salt, olditerations)
    # Encrypt with new pw iterations
    masterkey = xor_masterkey(original_masterkey, pw, salt, newiterations)
    return masterkey

def change_pw(masterkey, oldpw, oldsalt, iterations, pw):
    """Return masterkey encrypted with new pw"""
    # Decrypt key with old pw
    original_masterkey = xor_masterkey(masterkey, oldpw, oldsalt, iterations)
    # Encrypt with new pw
    salt = crypto_stream(64L)
    masterkey = xor_masterkey(original_masterkey, pw, salt, iterations)
    return masterkey, salt

def scan_qr_code():
    """Return auth url and nonce"""
    url = 'https://www.kevinx.net/sqrl/auth'
    nonce = binascii.hexlify(randombytes(crypto_box_NONCEBYTES))
    return (url, nonce)

def generate_site_keypair(masterkey, netloc):
    """Return keypair based on site and master key"""
    seed = crypto_generichash(netloc, k=masterkey)
    pk, sk = crypto_sign_seed_keypair(seed)
    return pk, sk

if __name__ == '__main__':
    test()
