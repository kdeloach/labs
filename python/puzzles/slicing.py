from __future__ import division
import random
from datetime import datetime

"""This experiment is to compare the performance differences between
array slicing with the list object and go-like slice structures.

My hypothesis is that performance benefits could be attained, in
situations where many array slicing operations are involved, by
substituting the python list object with a list-like wrapper, which
prevents copies of the list from being created per slice.

To test this hypothesis I created a structure called nonlist, which holds a
reference to a list, a start index, and a length. This object represents a
slice of the list. When nonlist is sliced, it returns a new nonlist object,
but does not copy the original list. Joining two nonlists together is
accomplished by increasing the length of one nonlist to encompass the other.

I used a quicksort implementation which uses list slicing and concat
operations to measure the performance differences between list and nonlist.
I also used a linear_slice function which simply performs len(lst) number
of slices to a list.

For quicksort, the builtin list outperformed nonlist by 20% to 25% for all
sizes of inputs I tested.

For linear_slice, the builtin list object performs 3x to 5x faster than
nonlist for input sizes less than 5,000. For input sizes >= 5,000, nonlist
outperforms list by a wide margin. Running linear_slice with 10,0000 items
took, on average, 60 seconds to complete for list, and 1.5 seconds to
complete for nonlist.

In conclusion, it seems that there could be performance benefits to using a
nonlist-type structure when working with very large amounts of data that
need to be processed and manipulated linearly. However, for small to
medium quantities of data, and for situations when your data manipulation
procedures have logorithmic or sub-linear running time, it seems that the
builtin list object is more than adequate."""

class nonlist(object):
    """Very limited implementation of a go-like slice object.
    This is a wrapper for list objects with the primary difference
    being that it will not create copies during slice operations.
    Modifying nonlist slices is the same as modifying the original list.

    Builtin list object:
    a = [1]
    b = a[:]
    b[0] = 2
    print a
    > [1]

    nonlist object:
    a = nonlist([1])
    b = a[:]
    b[0] = 2
    print a
    > [2]
    """

    __slots__ = ('lst', 'len', 'slice_start')

    def __init__(self, lst, slice_start=None, slice_end=None):
        if slice_start is None:
            slice_start = 0
        if slice_end is None:
            slice_end = len(lst)
        self.lst = lst
        self.len = slice_end - slice_start
        self.slice_start = slice_start

    def __len__(self):
        return self.len

    def __getitem__(self, key):
        try:
            return self.lst[self.slice_start + key]
        except TypeError:
            # step not supported on slice operations and we assume int indices
            start, stop, step = key.indices(self.len)
            return nonlist(self.lst, self.slice_start + start, self.slice_start + stop)

    def __setitem__(self, key, value):
        self.lst[self.slice_start + key] = value

    def __add__(self, other):
        """Non-contiguous slices are not supported. When joining multiple slices
        together the min and max slice indicies will be the bounds of the new slice."""
        slice_start = min(self.slice_start, other.slice_start)
        slice_end = max(self.slice_start + self.len, other.slice_start + other.len)
        self.len = slice_end - slice_start
        self.slice_start = slice_start
        return self

    def __iter__(self):
        for i in xrange(self.slice_start, self.slice_start + self.len):
            yield self.lst[i]

    def __repr__(self):
        return '[' + ', '.join(repr(self.lst[i])
            for i in xrange(self.slice_start, self.slice_start + self.len)) + ']'


# Source: http://c2.com/cgi/wiki?QuickSortInPython
def quicksort(L):
    if len(L) > 1:
        pivot = random.randrange(len(L))
        elements = L[:pivot] + L[pivot + 1:]
        left = [element for element in elements if element < L[pivot]]
        right = [element for element in elements if element >= L[pivot]]
        return quicksort(left) + [L[pivot]] + quicksort(right)
    return L


def linear_slice(L):
    while len(L) > 0:
        L[0] += len(L)
        L = L[1:]


def test(testlist, testproc, quantity):
    nums = range(quantity)
    random.shuffle(nums)
    x = testlist(nums)
    start = datetime.now()
    testproc(x)
    c = datetime.now() - start
    ms = (c.days * 24 * 60 * 60 + c.seconds) * 1000 + c.microseconds / 1000.0
    return ms


if __name__ == '__main__':
    import sys

    quantity = 1000
    if len(sys.argv) > 1:
        try:
            quantity = int(sys.argv[1])
        except ValueError:
            pass

    print 'for {0} elements...'.format(quantity)
    print 'nonlist linear_slice {0} MS elapsed'.format(test(nonlist, linear_slice, quantity))
    print 'nonlist quicksort {0} MS elapsed'.format(test(nonlist, quicksort, quantity))
    print 'list linear_slice {0} MS elapsed'.format(test(list, linear_slice, quantity))
    print 'list quicksort {0} MS elapsed'.format(test(list, quicksort, quantity))
