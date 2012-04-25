import ast
from ast import Num, Name, Add, Sub, Mult, Div, BinOp
from collections import defaultdict

def astparser(str):
    tree = ast.parse(str)
    return tree.body[0].value

def simpleparser(str):
    tokens = tokenize(str)
    return _simpleparser(tokens)
    
def _simpleparser(tokens):
    if len(tokens) == 1:
        return token2obj(tokens[0])
    elif tokens[0] == '(' and tokens[len(tokens) - 1] == ')':
        tokens = tokens[1:-1]
    i = indexOfHighestOrderOp(tokens)
    op = token2obj(tokens[i])
    left = _simpleparser(tokens[0:i])
    right = _simpleparser(tokens[i + 1:])
    return BinOp(op=op, left=left, right=right);
    
def indexOfHighestOrderOp(tokens):
    """Highest order of precedence operator in str (ignore anything between parens)"""
    # track of open/closed parnes
    parens = 0
    # store index of each op found
    ops = defaultdict(int)
    for n in range(len(tokens)):
        if parens < 0:
            raise InvalidExpressionFormat("parens don't match")
        token = tokens[n]
        if token == '(':
            parens += 1
        elif token == ')':
            parens -= 1
        # ignore anything between parens
        if parens > 0:
            continue
        if token in list('-+/*'):
            ops[token] = n
    for op in list('-+/*'):
        if ops[op]:
            return ops[op]
    
def isOp(char):
    return char in list('+-*/')
    
class InvalidExpressionFormat(Exception):
    pass
    
def token2obj(token):
    if token == '+':
        return Add()
    elif token == '-':
        return Sub()
    elif token == '*':
        return Mult()
    elif token == '/':
        return Div()
    try:
        return Num(int(token))
    except:
        pass
    return Name(id=token)
    
def tokenize(str):
    return [n for n in list(str) if n != ' ']
