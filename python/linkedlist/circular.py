
class Node(object):

    def __init__(self, value, next=None):
        self.value = value
        self.next = next

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

def print_list(node):
    n = A
    while n:
        print n
        n = n.next

        
if __name__ == '__main__':
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

    if is_circular(A):
        print "Cycle detected!"
    else:
        print_list(A)
