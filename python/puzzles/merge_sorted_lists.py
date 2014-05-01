
"""Write a function that takes two sorted lists of numbers and merges them into a single sorted list."""

def merge(a, b):
    result = []
    a = list(a)
    b = list(b)
    ai = 0
    bi = 0
    while ai < len(a) and bi < len(b):
        if a[ai] < b[bi]:
            result.append(a[ai])
            ai += 1
        else:
            result.append(b[bi])
            bi += 1
    result.extend(a[ai:])
    result.extend(b[bi:])
    return result

def test():
    assert merge([3], [1, 2]) == [1, 2, 3]
    assert merge([1, 2], [3]) == [1, 2, 3]
    assert merge([1, 3, 5], [2, 4, 6]) == [1, 2, 3, 4, 5, 6]
    assert merge([2, 4, 6], [1, 3, 5]) == [1, 2, 3, 4, 5, 6]

if __name__ == '__main__':
    test()
