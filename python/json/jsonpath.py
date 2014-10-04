import unittest

class jsonpath(object):
    def __init__(self, path):
        self.path = path

    def __getitem__(self, key):
        parts = self.path.split('.')[key]
        return '.'.join(parts)

class JsonPathTests(unittest.TestCase):
    def test_jsonpath(self):
        self.assertEqual(jsonpath('a.b')[0], 'a')
        self.assertEqual(jsonpath('a.b')[1], 'b')
        self.assertEqual(jsonpath('a.b')[0:2], 'a.b')
        self.assertEqual(jsonpath('a.b')[:], 'a.b')
        self.assertEqual(jsonpath('a.b')[-1], 'b')
        self.assertEqual(jsonpath('a.b.c')[0:3], 'a.b.c')
        self.assertEqual(jsonpath('a.b.c.d')[1:3], 'b.c')
        self.assertEqual(jsonpath('a.b.c.d')[-2:], 'c.d')
        self.assertRaises(IndexError, lambda: jsonpath('a')[1])

if __name__ == '__main__':
    unittest.main()
