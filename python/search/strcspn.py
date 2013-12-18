#!/usr/bin/env python

def strcspn(source, search):
    """Returns the index of the first occurrence in source of any character
    from search, or the length of source if no match is found."""
    char_to_index = dict((v, i) for i, v in enumerate(search))
    i = 0
    match = None
    for c in source:
        if c in char_to_index:
            if not match:
                match = (char_to_index[c], i)
            else:
                ci = char_to_index[c]
                match_ci, _ = match
                if ci < match_ci:
                    match = (char_to_index[c], i)
        i += 1
    if match:
        _, match_i = match
        return match_i
    return i

def test():
    assert strcspn("xycbxz", "abc") == 3
    assert strcspn("xyzbxz", "xyz") == 0
    assert strcspn("xyzbxz", "no match") == 6
    assert strcspn("xyzbxz", "") == 6
    assert strcspn("", "abc") == 0
    assert strcspn("", "") == 0

if __name__ == '__main__':
    test()
