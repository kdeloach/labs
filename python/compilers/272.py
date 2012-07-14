from collections import namedtuple

Token = namedtuple('Token', ['type', 'value'])

class Exercise(object):
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
        self.at = 0
        self.tokens = list(tokenize(target))
        self.writer = []
        self.symbols = SymbolTable()
        
    def match(self, value=None, type='symbol'):
        token = self.tokens[self.at]
        if token.type != type or (value and token.value != value):
            raise InvalidSyntax('Expected {0} "{1}" but received {2} "{3}"'. \
                format(type, value, token.type, token.value))
        self.at += 1
        return token
        
    def parse(self):
        self.writer = []
        self.Program()
        return ' '.join(self.writer)
        
    def snapshot(self):
        return (self.at, len(self.writer))
        
    def rewind(self, snapshot):
        old_at, old_writer_len = snapshot
        self.at = old_at
        self.writer = self.writer[:old_writer_len]
        
    def Program(self):
        self.Block()
        
    def Block(self):
        self.match('{')
        self.writer.append('{')
        self.symbols = SymbolTable(self.symbols)
        self.Decls()
        self.Stmts()
        self.match('}')
        self.writer.append('}')
        self.symbols = self.symbols.parent
        return True
        
    def Decls(self):
        while True:
            snapshot = self.snapshot()
            try:
                self.Decl()
            except:
                self.rewind(snapshot)
                break
            
    def Decl(self):
        type = self.match(type='word').value
        id = self.match(type='word').value
        self.symbols.put(id, type)
        self.match(';')
        
    def Stmts(self):
        keepGoing = True
        while keepGoing:
            try:
                keepGoing = self.Stmt()
            except ParsingComplete:
                break
            except:
                raise
        
    def Stmt(self):
        snapshot = self.snapshot()
        try:
            if self.Block():
                return True
        except InvalidSyntax:
            self.rewind(snapshot)
        try:
            self.Factor()
            self.match(';')
            return True
        except InvalidSyntax:
            self.rewind(snapshot)
        return False
        
    def Factor(self):
        id = self.match(type='word').value
        type = self.symbols.get(id)
        self.writer.append('{0}:{1};'.format(id, type))

class InvalidSyntax(Exception):
    pass

class ParsingComplete(Exception):
    pass
    
class UndeclaredVariable(Exception):
    pass

class SymbolTable(object):
    """ Store lexeme name and value information for a given scope """
    
    def __init__(self, parent=None):
        self.parent = parent
        self.table = dict()
        
    def get(self, key):
        try:
            return self.table[key]
        except KeyError:
            if not self.parent:
                raise UndeclaredVariable(key)
            else:
                return self.parent.get(key)
        
    def put(self, key, value):
        self.table[key] = value

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
            yield Token('number', n)
        elif c.isalpha():
            letters = []
            while True:
                letters.append(c)
                c = target[i + 1]
                if not c.isalpha() and not c.isdigit():
                    break
                i += 1
            word = ''.join(letters)
            yield Token('word', word)
        else:
            yield Token('symbol', c)
        i += 1

input = '{ int x; char y; { bool y; x; y; } x; y; }'
expected = '{ { x:int; y:bool; } x:int; y:char; }'
actual = Exercise(input).parse()

print actual

assert actual == expected
