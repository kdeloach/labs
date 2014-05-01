from __future__ import division

import random
from math import floor

def insertion_sort(lst):
    for i in range(1, len(lst)):
        n = lst[i]
        k = i - 1
        while k >= 0 and lst[k] > n:
            lst[k + 1] = lst[k]
            k -= 1
        lst[k + 1] = n

def merge_sort(lst):
    return _merge_sort(lst, 0, len(lst) // 2, len(lst))

def _merge_sort(lst, p, q, r):
    sublist_len = r - p
    if sublist_len <= 1:
        return lst
    elif sublist_len == 2:
        if lst[q] < lst[p]:
            lst[q], lst[p] = lst[p], lst[q]
        return lst

    _merge_sort(lst, p, (p + q) // 2, q)
    _merge_sort(lst, q, (q + r) // 2, r)

    Ai = 0
    Bi = 0
    An = q - p
    Bn = r - q

    A = [lst[p + i] for i in range(An)]
    B = [lst[q + i] for i in range(Bn)]

    i = p

    while Ai < An and Bi < Bn:
        if A[Ai] < B[Bi]:
            lst[i] = A[Ai]
            Ai += 1
        else:
            lst[i] = B[Bi]
            Bi += 1
        i += 1

    lst[i:r] = A[Ai:] + B[Bi:]

    return lst

def max_heapify(lst, heap_size, i):
    left = i * 2
    right = left + 1
    largest = i
    if left < heap_size and lst[left] > lst[largest]:
        largest = left
    if right < heap_size and lst[right] > lst[largest]:
        largest = right
    if largest != i:
        lst[i], lst[largest] = lst[largest], lst[i]
        max_heapify(lst, heap_size, largest)

def build_max_heap(lst):
    heap_size = len(lst)
    i = len(lst) // 2
    while i >= 0:
        max_heapify(lst, heap_size, i)
        i -= 1

def heapsort(lst):
    build_max_heap(lst)
    heap_size = len(lst) - 1
    i = heap_size
    while i > 0:
        lst[0], lst[i] = lst[i], lst[0]
        max_heapify(lst, heap_size, 0)
        heap_size -= 1
        i -= 1

def quicksort(lst):
    return _quicksort(lst, 0, len(lst) - 1)

def _quicksort(lst, p, r):
    if p < r:
        q = quicksort_partition(lst, p, r)
        _quicksort(lst, p, q - 1)
        _quicksort(lst, q + 1, r)

def quicksort_partition(lst, p, r):
    pivot = lst[r]
    i = p
    k = p - 1
    while i < r:
        if lst[i] < pivot:
            k += 1
            lst[k], lst[i] = lst[i], lst[k]
        i += 1
    k += 1
    lst[k], lst[i] = lst[i], lst[k]
    return k

def quicksort_partition_hoare(lst, p, r):
    i = p
    k = r
    pivot = lst[p]
    while True:
        while lst[i] < pivot:
            i += 1
        while lst[k] > pivot:
            k -= 1
        if i < k:
            lst[i], lst[k] = lst[k], lst[i]
        else:
            return i


# A = [8, 9, 4, 3, 14, 1, 7, 16, 10, 2]
# print A
# heapsort(A)
# print A

x = range(10000)
random.shuffle(x)
print x
quicksort(x)
print x
