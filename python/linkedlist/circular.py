import sys

class Node(object):
    def __init__(self, value, next=None):
        self.value = value
        self.next = next

    def __iter__(self):
        n = self
        while n:
            yield n
            n = n.next

    def __str__(self):
        return '<' + self.value + '>'

def is_circular(node):
    slow = node
    fast1 = node
    fast2 = node
    while slow:
        fast1 = fast2.next if fast2 else None
        fast2 = fast1.next if fast1 else None
        if slow is fast1 or slow is fast2:
            return True
        slow = slow.next
    return False

def main():
    A = Node('A')
    B = Node('B')
    C = Node('C')
    D = Node('D')
    E = Node('E')
    F = Node('F')

    A.next = B
    B.next = C
    C.next = D
    D.next = E
    E.next = F

    if len(sys.argv) > 1 and sys.argv[1] == 'cycle':
        E.next = A # Whoops

    if is_circular(A):
        print "Cycle detected!"
    else:
        for node in A:
            print node

if __name__ == '__main__':
    main()
