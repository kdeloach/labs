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

def test_keypair_box():
    # Test that either pair of private/public keys can decrypt a message
    pkA, skA = crypto_box_keypair()
    pkB, skB = crypto_box_keypair()
    n = randombytes(crypto_box_NONCEBYTES)
    cipher = crypto_box("hello world", n, pkB, skA)
    try:
        x = crypto_box_open(cipher, n, pkA, skB)
        y = crypto_box_open(cipher, n, pkB, skA)
        print x
        print y
        assert x == y
    except ValueError:
        print 'decryption error'

def test_identity_unlock():
    # Test identity unlock procedure
    ilk, iuk = crypto_box_keypair()
    suk, rlk = crypto_box_keypair()
    vuk = make_public(dhka(ilk, rlk))
    print 'ilk', binascii.hexlify(ilk)
    print 'iuk', binascii.hexlify(iuk)
    print 'rlk', binascii.hexlify(rlk)
    print 'suk', binascii.hexlify(suk)
    print 'vuk', binascii.hexlify(vuk)

    # Reconstruct private key
    ursk = dhka(suk, iuk)
    print 'ursk', binascii.hexlify(ursk)

    # Server-side verification
    #n = randombytes(crypto_box_NONCEBYTES)
    #cipher = crypto_box("revoke key", n, vuk, ursk)
    sm = crypto_sign("test", ursk)
    crypto_sign_open(sm, vuk)

def test_make_public():
    # Test creating public key from private key
    _, sk = crypto_box_keypair()
    pk = make_public(sk)
    print '_', binascii.hexlify(_)
    print 'pk', binascii.hexlify(pk)
    print 'sk', binascii.hexlify(sk)
    assert pk == _

def make_public(sk):
    return crypto_scalarmult_curve25519_base(sk)

def dhka(pk, sk):
    return crypto_scalarmult_curve25519(sk, pk)

def test_dhka():
    # Test creating a shared secret between two keypairs
    pkA, skA = crypto_box_keypair()
    pkB, skB = crypto_box_keypair()
    x = dhka(pkA, skB)
    y = dhka(pkB, skA)
    print 'x', binascii.hexlify(x)
    print 'y', binascii.hexlify(y)
    assert x == y

if __name__ == '__main__':
    #test()
    #test_keypair_box()
    test_identity_unlock()
    #test_make_public()
    #test_dhka()

