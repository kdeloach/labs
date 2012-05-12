import tornado
from tornado.options import options, define
import os
import simplejson
from pprint import pprint
    
def load_options():
    if 'dsn' in options:
        return
    root = os.path.join(os.path.dirname(__file__), '../')
    define('port', default=80)
    define('debug', default=True, help='enables logging to console')
    define('cookie_secret')
    define('dsn', help='database connection string')
    define('static_path')
    define('template_path')
    tornado.options.parse_config_file(os.path.join(root, 'site.conf'))
    tornado.options.parse_command_line()