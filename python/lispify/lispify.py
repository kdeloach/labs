import ast
import types
from optparse import OptionParser
import os.path

def lispify(strexp, simplify=False):
    tree = ast.parse(strexp)
    expr = tree.body[0].value
    if simplify:
        expr = SimplifyNode().visit(expr)
    return _lispify(expr)

def _lispify(expr):
    if type(expr) is ast.Num:
        return str(expr.n)
    elif type(expr) is ast.Name:
        return str(expr.id)
    elif type(expr) is ast.Add:
        return '+'
    elif type(expr) is ast.Sub:
        return '-'
    elif type(expr) is ast.Mult:
        return '*'
    elif type(expr) is ast.Div:
        return '/'
    elif type(expr) is ast.BinOp:
        return '(%s %s %s)' % (_lispify(expr.op), _lispify(expr.left), _lispify(expr.right))
    print type(expr).__name__
    
def simplify(expr):
    if type(expr) is ast.Num:
        return expr.n
    elif type(expr) is ast.BinOp:
        fn = opfn(expr.op)
        return fn(simplify(expr.left), simplify(expr.right))
    raise Exception('unable to simplify')
    
def opfn(op):
    if type(op) is ast.Add:
        return lambda a, b: a + b
    elif type(op) is ast.Sub:
        return lambda a, b: a - b
    elif type(op) is ast.Mult:
        return lambda a, b: a * b
    elif type(op) is ast.Div:
        return lambda a, b: a / b
    raise NotImplementedError(type(op).__name__)
    
class SimplifyNode(ast.NodeTransformer):
    def visit_BinOp(self, node):
        try:
            return ast.Num(n=simplify(node))
        except:
            pass
        return ast.NodeTransformer.generic_visit(self, node)
    
def runtests(simplify=False):
    expressions = [
        ('3', '3', '3'),
        ('1 + 1', '(+ 1 1)', '2'),
        ('2 * 5 + 1', '(+ (* 2 5) 1)', '11'),
        ('2 * (5 + 1)', '(* 2 (+ 5 1))', '12'),
        ('3 * x + (9 + y) / 4', '(+ (* 3 x) (/ (+ 9 y) 4))', '(+ (* 3 x) (/ (+ 9 y) 4))'),
        ('3 * 2 + x', '(+ (* 3 2) x)', '(+ 6 x)'),
        ('3 * (8 / (2 * 2)) + x', '(+ (* 3 (/ 8 (* 2 2))) x)', '(+ 6 x)')
    ]
    for (strexp, expected, expected_simplified) in expressions:
        print strexp
        result = lispify(strexp, simplify=simplify)
        print result, "\n"
        if simplify:
            assert result == expected_simplified, 'Expected: %s, Actual: %s' % (expected_simplified, result)
        else:
            assert result == expected, 'Expected: %s, Actual: %s' % (expected, result)

parser = OptionParser(usage='Usage: %prog [options] filename')
parser.add_option('-r', action='store_true', dest='simplify', default=False,
                  help='simplify expressions as much as possible')
parser.add_option('-t', action='store_true', dest='runtests', default=False,
                  help='run tests')
(options, args) = parser.parse_args()

if options.runtests:
    runtests(simplify=options.simplify)
    exit()
    
if len(args) == 0:
    parser.print_help()
    exit()
    
filename, = args
if not os.path.exists(filename):
    print 'File not found'
    exit()

with open(filename) as fd:
    for line in fd.readlines():
        line = line.strip()
        print line
        try:
            print lispify(line, simplify=options.simplify), "\n"
        except:
            print 'Unable to parse expression'
    
    
