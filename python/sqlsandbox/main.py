import tornado
import tornado.ioloop
from tornado.options import options
import os

import sqlsandbox.handlers
import sqlsandbox.util

sqlsandbox.util.load_options()

settings = {
    'static_path': options.static_path,
    'template_path': options.template_path,
    'cookie_secret': options.cookie_secret,
    'autoescape': None,
    'debug': options.debug
}

routes = [
    (r"/static/(.*)", tornado.web.StaticFileHandler, {'path': 'static'}),
    (r"/.*", sqlsandbox.handlers.IndexHandler)
]
            
if __name__ == '__main__':
    application = tornado.web.Application(routes, **settings)
    application.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()
