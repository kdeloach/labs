from tornado.web import HTTPError, RequestHandler
from .gendb import create_tables, populate_test_data
from sqlalchemy import *
import simplejson as json
    
class IndexHandler(RequestHandler):
    def get(self):
        self.render('index.html', query='', schema='')
        
    def post(self):
        self.set_header('Content-Type', 'application/json')
        result = ''
        try:
            schema = json.loads(self.get_argument('schema', ''))
            query = self.get_argument('query', '')
            
            engine = create_engine('sqlite:///:memory:', echo=False)
            metadata = create_tables(schema)
            metadata.create_all(engine)
            populate_test_data(metadata, engine)
            
            res = engine.execute(query)
            rows = [row.items() for row in res.fetchall()]
            rows = [[v for (k, v) in row] for row in rows]
            result = json.dumps(rows)
        except Exception as ex:
            #raise
            result = json.dumps([[str(ex)]])
        self.write(result)
