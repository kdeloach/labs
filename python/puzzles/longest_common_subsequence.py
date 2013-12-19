
# Naive O(n * m2) solution

def longest_common_subsequence(*words):
    """Longest Common Subsequence
    Implement a function that accepts a set of k strings s1,...,sk where the longest string has length n, and returns the longest common subsequence of the strings. A longest common subsequence is a string s that is a subsequence of each si individually such that no longer string has the same property. s is a subsequence of si if si can be transformed into s by removing characters.

    A longest common subsequence of "afternoon", "yesterday", and "tomorrow" is "tr", so 2 should be returned."""
    words = list(words)
    if len(words) == 0:
        return None
    if len(words) == 1:
        return words[0]
    A = words.pop()
    B = longest_common_subsequence(*words)
    result = []
    for i in xrange(len(A)):
        seq = []
        ai = i
        bi = 0
        bi_start = 0
        while ai < len(A):
            bi = bi_start
            while bi < len(B) and ai < len(A):
                if A[ai] == B[bi]:
                    seq.append(A[ai])
                    ai += 1
                    bi_start = bi + 1
                bi += 1
            ai += 1
        if len(seq) > len(result):
            result = seq
    result = ''.join(result)
    return result

def test():
    assert longest_common_subsequence() == None
    assert longest_common_subsequence("a") == "a"
    assert longest_common_subsequence(".a.b.c.", "axbzc") == "abc"
    assert longest_common_subsequence("afternoon", "yesterday", "tomorrow") == "tr"
    assert longest_common_subsequence("sally", "harry") == "ay"

if __name__ == '__main__':
    test()

