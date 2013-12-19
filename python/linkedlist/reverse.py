
def reversed_linked_list(head):
    if not head:
        return None
    result = None
    while head:
        value, next_node = head
        result = (value, result)
        head = next_node
    return result

def main():
    L = ('A', ('B', ('C', None)))
    print L
    print reversed_linked_list(L)

if __name__ == '__main__':
    main()
