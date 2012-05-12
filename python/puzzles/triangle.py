 
# Source: http://marketing.yodle.com/downloads/puzzles/triangle.html
 
def linemax(f):
    i = 0
    for line in f:
        # find the highest value within +/- 1 position
        # of the max value on the previous line
        lst = [s for s in str(line).strip().split(' ') if s]
        ia = max(i - 1, 0)
        # list of: i-1, i, i+1
        lst = lst[ia:i+2]
        n = max(lst)
        i = lst.index(n) + ia
        yield int(n)
 
with open('triangle.txt') as f:
    print reduce(lambda a, b: a + b, linemax(f))
