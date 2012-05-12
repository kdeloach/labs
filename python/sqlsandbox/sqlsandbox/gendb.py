from sqlalchemy import *
import simplejson as json
import random
import datetime

NUM_TEST_ROWS = 50
        
def getcoltype(coltype):
    coltype = coltype.lower()
    if coltype == 'bigint' or coltype == 'biginteger':
        return BigInteger
    elif coltype == 'bool' or coltype == 'boolean' or coltype == 'bit':
        return Boolean
    elif coltype == 'date':
        return Date
    elif coltype == 'datetime':
        return DateTime
    elif coltype == 'int' or coltype == 'integer':
        return Integer
    elif coltype == 'string' or coltype == 'varchar':
        return String(40)
    elif coltype == 'text':
        return Text
    elif coltype == 'time':
        return Time
    return String(40)
       
def coltestdata(col):
    if len(col.foreign_keys):
        return random.randrange(1, NUM_TEST_ROWS)
    if isinstance(col.type, BigInteger) or isinstance(col.type, Integer):
        return random.randrange(1, 10000)
    elif isinstance(col.type, Boolean):
        return random.choice([True, False])
    elif isinstance(col.type, Date):  
        return datetime.date.today() - datetime.timedelta(days=random.randrange(365 * 5))
    elif isinstance(col.type, DateTime):  
        return datetime.datetime.today() - datetime.timedelta(days=random.randrange(365 * 5))
    elif isinstance(col.type, Time):  
        return datetime.time(hour=random.randrange(24), minute=random.randrange(59))
    elif isinstance(col.type, String):
        return ''.join([random.choice("abcdefghijklmnopqrstuvwxyz   ") for n in range(col.type.length or 40)])
    return None
       
def create_tables(schema):
    metadata = MetaData()
    for tblname in schema:
        cols = []
        for col in schema[tblname]:
            if not type(col) is dict:
                col = dict(name=col)
            args = []
            kwargs = dict()
            if not 'name' in col:
                raise Exception('Missing "name" property in column definition')
            colname = col['name']
            coltype = getcoltype(col.get('type', ''))
            primary_key = col.get('primary_key', colname.lower() == 'id')
            if 'foreign_key' in col:
                coltype = Integer
                args.append(ForeignKey(col['foreign_key']))
            elif '_' in colname:
                srctbl = colname.split('_')[0]
                if srctbl in schema:
                    coltype = Integer
                    args.append(ForeignKey(colname.replace('_', '.')))
            kwargs.update(nullable=col.get('nullable', True))
            kwargs.update(unique=col.get('unique', False))
            if primary_key:
                coltype = Integer
                kwargs.update(primary_key=True, nullable=False)
            cols.append(Column(colname, coltype, *args, **kwargs))
        tbl = Table(tblname, metadata, *cols)
    return metadata
    
def populate_test_data(metadata, engine):
    for tbl in metadata.sorted_tables:
        for i in range(NUM_TEST_ROWS):
            vals = dict()
            for col in tbl.c:
                if col.name in tbl.primary_key:
                    continue
                vals.update({col.name: coltestdata(col)})
            engine.execute(tbl.insert().values(**vals))
