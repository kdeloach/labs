 
def linemax(f):
    i = 0
    for line in f:
        lst = [s for s in str(line).strip().split(' ') if s]
        a = max(i - 1, 0)
        lst = lst[a:i + 2]
        n = max(lst)
        i = lst.index(n) + a
        yield int(n)
 
with open('triangle.txt') as f:
    print reduce(lambda a, b: a + b, linemax(f))
