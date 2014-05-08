import base64

def encode(value):
    return base64.urlsafe_b64encode(value).rstrip('=')

def decode(value):
    # Convert unicode
    value = str(value)
    return base64.urlsafe_b64decode(value + '=' * (4 - len(value) % 4))
