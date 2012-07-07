class exercise_a(object):
    """ S -> + S S | - S S | a """
    
    def __init__(self, target):
        self.target = target
        self.at = 0

    def parse(self):
        while self.at < len(self.target):
            yield self.S()
            
    def S(self):
        if self.current() == '+':
            self.match('+')
            self.white()
            a = self.S()
            self.white()
            b = self.S()
            return ('+', a, b)
        elif self.current() == '-':
            self.match('-')
            self.white()
            a = self.S()
            self.white()
            b = self.S()
            return ('-', a, b)
        else:
            self.match('a')
            self.white()
            return 'a'
        return None
        
    def white(self):
        while self.current() == ' ':
            self.match(' ')
        
    def current(self):
        try:
            return self.target[self.at]
        except:
            pass
        
    def match(self, c):
        ch = self.target[self.at]
        #print "{%d:%s}" % (self.at, c)
        if c != ch:
            raise Exception('Invalid syntax: Expected %s but found %s' % (c, ch))
        self.at += 1
        
    def __str__(self):
        return str(tuple(self.parse()))

for target in ['a', 'ab', 'aa', 'a a', '+aa', '+ a a', '+ -a +aa a']:
    try:
        res = exercise_a(target)
        print '%s --> %s ' % (target, res)
    except Exception as ex:
        msg, = ex.args
        print '%s (%s)' % (target, msg)
