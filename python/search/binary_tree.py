#!/usr/bin/env python
from random import shuffle
from StringIO import StringIO
from Bio import Phylo

def binary_tree_add(tree, c):
    if tree is None:
        return (c, None, None)
    root, left, right = tree
    if c < root:
        tree = (root, binary_tree_add(left, c), right)
    elif c > root:
        tree = (root, left, binary_tree_add(right, c))
    return tree

def binary_tree_find(tree, c):
    if tree is None:
        return False
    root, left, right = tree
    if c < root:
        return binary_tree_find(left, c)
    elif c > root:
        return binary_tree_find(right, c)
    return c == root

def main():
    pattern = list('abcdefg')
    shuffle(pattern)
    print ''.join(pattern)

    tree = reduce(binary_tree_add, pattern, None)

    assert binary_tree_find(tree, 'a') == True
    assert binary_tree_find(tree, 'g') == True
    assert binary_tree_find(tree, 'z') == False

    output_tree = Phylo.read(StringIO(str(tree)), "newick")
    Phylo.draw_ascii(output_tree)

if __name__ == '__main__':
    main()
