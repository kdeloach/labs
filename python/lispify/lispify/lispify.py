import ast
from ast import Num, Name, Add, Sub, Mult, Div, BinOp
import types
from .parsers import astparser

def lispify(strexp, simplify=False, parser=None):
    if not parser:
        parser = astparser
    expr = parser(strexp)
    if simplify:
        expr = SimplifyNode().visit(expr)
    return _lispify(expr)

def _lispify(expr):
    if isinstance(expr, Num):
        return str(expr.n)
    elif isinstance(expr, Name):
        return expr.id
    elif isinstance(expr, Add):
        return '+'
    elif isinstance(expr, Sub):
        return '-'
    elif isinstance(expr, Mult):
        return '*'
    elif isinstance(expr, Div):
        return '/'
    elif isinstance(expr, BinOp):
        return '(%s %s %s)' % (_lispify(expr.op), _lispify(expr.left), _lispify(expr.right))
    
def simplify(expr):
    if isinstance(expr, Num):
        return expr.n
    elif isinstance(expr, BinOp):
        return evalop(expr.op, simplify(expr.left), simplify(expr.right))
    raise UnableToSimplify()
    
def evalop(op, a, b):
    if isinstance(op, Add):
        return a + b
    elif isinstance(op, Sub):
        return a - b
    elif isinstance(op, Mult):
        return a * b
    elif isinstance(op, Div):
        return a / b
    raise NotImplementedError(type(op).__name__)
    
class UnableToSimplify(Exception):
    pass
    
class SimplifyNode(ast.NodeTransformer):
    def visit_BinOp(self, node):
        try:
            return Num(n=simplify(node))
        except UnableToSimplify:
            pass
        return ast.NodeTransformer.generic_visit(self, node)
 