from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from tornado.options import options
from .util import load_options

load_options()

engine = create_engine(options.dsn, echo=options.echosql)
Session = scoped_session(sessionmaker(bind=engine))
Base = declarative_base()
