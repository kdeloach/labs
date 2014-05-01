from __future__ import division

import operator
import itertools
import collections

def myhash(data):
    result = 0
    for i, x in enumerate(data):
        result ^= ord(x) << 5 * i
    return result

testdata = list(itertools.permutations('abcxyz'))
hashed = [(myhash(p), ''.join(p)) for p in testdata]
hashed = sorted(hashed, key=operator.itemgetter(0))
grouped = [(k, len(list(v))) for k, v in itertools.groupby(hashed, operator.itemgetter(0))]

total_collisions = sum(n - 1 for k, n in grouped if n > 1)

print str(len(grouped)) + ' unique hashes for ' + str(len(testdata)) + ' items'
print 'Total collisions: {0}'.format(total_collisions)
