import urlparse
import base64url
from collections import namedtuple
from pysodium import *
from PBKDF import PBKDF2

SALT_LEN = 8L
IDK_LEN = 32L
PW_VERIFIER_LEN = 16L

class TIF(object):
    # Found idk match
    IdMatch = 0x1
    # Found pidk match
    PreviousIdMatch = 0x2
    # Client IP matches encrypted IP
    IpMatch = 0x4
    # User account is enabled
    SqrlEnabled = 0x8
    # User already logged in
    LoggedIn = 0x10
    # User can register
    AccountCreationEnabled = 0x20
    # Error processing command
    CommandFailed = 0x40
    # Server error
    SqrlFailure = 0x80

def has_flag(mask, flag):
    return mask & flag == flag
    
SqrlUser = namedtuple('SqrlUser', 'identity pw')
SqrlAccount = namedtuple('SqrlAccount', 'user url suk vuk tif')

class SqrlRequestBody(object):
    def __init__(self):
        self.client = SqrlRequestBodyClientArgs()
        self.server = ''
        self.ids = ''
        self.pids = ''
        self.urs = ''

    def serialize(self):
        return '&'.join([
            'client=' + self.client.serialize(),
            'server=' + base64url.encode(self.server),
            'ids=' + base64url.encode(self.ids),
            'pids=' + (base64url.encode(self.pids) if len(self.pids) > 0 else ''),
            'urs=' + (base64url.encode(self.urs) if len(self.urs) > 0 else '')
            ])

    @classmethod
    def deserialize(cls, content):
        result = cls()
        data = urlparse.parse_qs(content)
        result.client = SqrlRequestBodyClientArgs.deserialize(data['client'][0])
        result.server = base64url.decode(data['server'][0])
        result.ids = base64url.decode(data['ids'][0])
        result.pids = base64url.decode(data['pids'][0]) if 'pids' in data else ''
        result.urs = base64url.decode(data['urs'][0]) if 'urs' in data else ''
        return result

    def __str__(self):
        return "SqrlRequestBody(" + self.serialize() + ")"


class SqrlRequestBodyClientArgs(object):
    def __init__(self):
        self.ver = 1
        self.cmd = ''
        self.idk = ''
        self.pidk = ''
        self.suk = ''
        self.vuk = ''

    def serialize(self):
        return base64url.encode('&'.join([
            'ver=' + str(self.ver),
            'cmd=' + str(self.cmd),
            'idk=' + base64url.encode(self.idk),
            'pidk=' + (base64url.encode(self.pidk) if len(self.pidk) > 0 else ''),
            'suk=' + (base64url.encode(self.suk) if len(self.suk) > 0 else ''),
            'vuk=' + (base64url.encode(self.vuk) if len(self.vuk) > 0 else '')
            ]))

    @classmethod
    def deserialize(cls, content):
        result = cls()
        data = urlparse.parse_qs(base64url.decode(content))
        result.ver = data['ver'][0]
        result.cmd = data['cmd'][0]
        result.idk = base64url.decode(data['idk'][0])
        result.pidk = base64url.decode(data['pidk'][0]) if 'pidk' in data else ''
        result.suk = base64url.decode(data['suk'][0]) if 'suk' in data else ''
        result.vuk = base64url.decode(data['vuk'][0]) if 'vuk' in data else ''
        return result


class SqrlResponse(object):
    def __init__(self):
        self.tif = 0
        self.suk = ""
        self.vuk = ""
        
    def serialize(self):
        return '&'.join([
            'tif=' + str(self.tif),
            'suk=' + (base64url.encode(self.suk) if len(self.suk) > 0 else ''),
            'vuk=' + (base64url.encode(self.vuk) if len(self.vuk) > 0 else '')
            ])

    @classmethod
    def deserialize(cls, content):
        result = cls()
        data = urlparse.parse_qs(content)
        result.tif = int(data['tif'][0])
        result.suk = base64url.decode(data['suk'][0]) if 'suk' in data else ''
        result.vuk = base64url.decode(data['vuk'][0]) if 'vuk' in data else ''
        return result

    def __str__(self):
        return "SqrlResponse(" + self.serialize() + ")"
