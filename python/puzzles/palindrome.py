import string
from itertools import izip

"""Determine if a given string is a palindrome."""

def palindrome(word):
    if not word:
        return False
    if len(word) < 2:
        return True
    word = word.translate(None, string.punctuation + string.whitespace).lower()
    from_start = xrange(0, len(word) / 2 + 1)
    from_end = (len(word) - i - 1 for i in from_start)
    return all(word[j] == word[k] for j, k in izip(from_start, from_end))

def test():
    assert palindrome('Test') == False
    assert palindrome('A man, a plan, a canal: Panama') == True
    assert palindrome('Was it a car or a cat I saw?') == True

if __name__ == '__main__':
    test()
