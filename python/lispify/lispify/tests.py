import ast
import types
from .lispify import lispify

def runtests(simplify=False, parser=None):
    tests = [
        ('3', '3', '3'),
        ('1 + 1', '(+ 1 1)', '2'),
        ('2 + 5 * 1', '(+ 2 (* 5 1))', '7'),
        ('2 * (5 + 1)', '(* 2 (+ 5 1))', '12'),
        ('3 * x + (9 + y) / 4', '(+ (* 3 x) (/ (+ 9 y) 4))', '(+ (* 3 x) (/ (+ 9 y) 4))'),
        ('3 * 2 + x', '(+ (* 3 2) x)', '(+ 6 x)'),
        ('3 * (8 / (2 * 2)) + x', '(+ (* 3 (/ 8 (* 2 2))) x)', '(+ 6 x)'),
        ('3 + (8 / (2 * 2)) * x', '(+ 3 (* (/ 8 (* 2 2)) x))', '(+ 3 (* 2 x))')
    ]
    for (strexp, expected, expected_simplified) in tests:
        print strexp
        result = lispify(strexp, simplify=simplify, parser=parser)
        print result
        if simplify:
            if result != expected_simplified:
                print 'Expected: %s, Actual: %s' % (expected_simplified, result)
        elif result != expected:
            print 'Expected: %s, Actual: %s' % (expected, result)
        print ''
