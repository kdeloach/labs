"""Simple storage format used for testing only.

Will eventually be replaced by SQRL Secure Storage Format (SSF).
"""
import struct

fmt = '< 32s 8s I 16s 32s'
SqrlStruct = struct.Struct(fmt)

class SqrlIdentity(object):
    def __init__(self, masterkey, salt, pw_iterations, pw_verify, identity_lock_key):
        self.masterkey = masterkey
        self.salt = salt
        self.pw_iterations = pw_iterations
        self.pw_verify = pw_verify
        self.identity_lock_key = identity_lock_key

def load(fs):
    return SqrlIdentity(*SqrlStruct.unpack(fs.read()))

def save(fs, identity):
    o = identity
    fs.write(SqrlStruct.pack(o.masterkey,
                             o.salt,
                             o.pw_iterations,
                             o.pw_verify,
                             o.identity_lock_key))
