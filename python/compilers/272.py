import traceback

class exercise(object):
    """
    program -> block
    block   -> { decls stmts }
    decls   -> decls decl
             | ∅
    decl    -> type id ;
    stmts   -> stmts stmt 
             | ∅
    stmt    -> block 
             | factor ;
    factor  -> id
    """

    def __init__(self, target):
        self.target = target
        self.at = 0
        self.tokens = list(tokenize(target))
        self.writer = []
        self.symbols = symboltable()
        
    def match(self, value=None, type='symbol'):
        token = self.tokens[self.at]
        t_type, t_value = token
        if t_type != type or (value and t_value != value):
            raise InvalidSyntax('Expected {0} "{1}" but received {2} "{3}"'. \
                format(type, value, t_type, t_value))
        self.at += 1
        return token
        
    def parse(self):
        self.writer = []
        self.Program()
        return ' '.join(self.writer)
        
    def rewind(self, snapshot):
        old_at, old_writer_len = snapshot
        self.at = old_at
        self.writer = self.writer[:old_writer_len]
        
    def snapshot(self):
        return (self.at, len(self.writer))
        
    def Program(self):
        self.Block()
        
    def Block(self):
        self.match('{')
        self.writer.append('{')
        self.symbols = symboltable(self.symbols)
        try:
            self.Decls()
        except ParsingComplete:
            pass
        try:
            self.Stmts()
        except ParsingComplete:
            pass
        self.match('}')
        self.writer.append('}')
        self.symbols = self.symbols.parent
        
    def Decls(self):
        self.Decls_b()
        #self.Decl()
        
    def Decls_b(self):
        self.Decl()
        self.Decls()
        
    def Decl(self):
        snapshot = self.snapshot()
        try:
            _, type = self.match(type='word')
            _, id = self.match(type='word')
            self.symbols.put(id, type)
            self.match(';')
            return
        except:
            self.rewind(snapshot)
        raise ParsingComplete()
        
    def Stmts(self):
        self.Stmts_b()
        #self.Stmt()
        
    def Stmts_b(self):
        self.Stmt()
        self.Stmts()
        
    def Stmt(self):
        snapshot = self.snapshot()
        try:
            self.Block()
            return
        except:
            self.rewind(snapshot)
        try:
            self.Factor()
            self.match(';')
            return
        except:
            self.rewind(snapshot)
        raise ParsingComplete()
        
    def Factor(self):
        _, id = self.match(type='word')
        type = self.symbols.get(id)
        if not type:
            type = 'undeclared'
        self.writer.append('{0}:{1};'.format(id, type))


class InvalidSyntax(Exception):
    pass

class ParsingComplete(Exception):
    pass
        

class symboltable(object):
    """ Store lexeme name and value information for a given scope """
    
    def __init__(self, parent=None):
        self.parent = parent
        self.table = dict()
        
    def get(self, key):
        if key in self.table:
            return self.table[key]
        if not self.parent:
            return None
        return self.parent.get(key)
        
    def put(self, key, value):
        self.table.update({key: value})


def tokenize(target):
    i = 0
    while i < len(target):
        c = target[i]
        if c == ' ':
            pass
        elif c.isdigit():
            n = 0
            while True:
                n = n * 10 + int(c)
                c = target[i + 1]
                if not c.isdigit():
                    break
                i += 1
            yield ('number', n)
        elif c.isalpha():
            letters = []
            while True:
                letters.append(c)
                c = target[i + 1]
                if not c.isalpha() and not c.isdigit():
                    break
                i += 1
            word = ''.join(letters)
            yield ('word', word)
        else:
            yield('symbol', c)
        i += 1

input = '{ int x; char y; { bool y; x; y; } x; y; }'
expected = '{ { x:int; y:bool; } x:int; y:char; }'
actual = exercise(input).parse()
assert actual == expected
