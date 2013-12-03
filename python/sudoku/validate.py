from itertools import chain

ONE_TO_NINE = set([1, 2, 3, 4, 5, 6, 7, 8, 9])

class Grid(object):
    def __init__(self, data):
        self.data = data

    # Return each 3x3 grid, left-to-right, top-to-bottom.
    def iter_blocks(self):
        for y in xrange(3):
            for x in xrange(3):
                mx = x * 3
                my = y * 3
                yield [self.cell_at(mx + j, my + k) for j in xrange(3) for k in xrange(3)]

    # Return each row.
    def iter_rows(self):
        for y in xrange(9):
            yield [self.cell_at(x, y) for x in xrange(9)]

    # Return each column.
    def iter_cols(self):
        for x in xrange(9):
            yield [self.cell_at(x, y) for y in xrange(9)]

    def cell_at(self, x, y):
        return self.data[y * 9 + x]

    def __str__(self):
        result = []
        for i, c in enumerate(self.data):
            if i % 9 == 0:
                result.append("\n")
            if i % 27 == 0:
                result.append("|-----------\n")
            if i % 3 == 0:
                result.append("|")
            result.append(c)
        return ''.join(result)

# True if block contains the numbers 1-9 unique.
def is_valid_block(block):
    try:
        block = set(map(int, block))
    except ValueError:
        return False
    return len(block) == 9 and block == ONE_TO_NINE

def is_valid_solution(grid):
    if len(grid) < 81:
        return False
    grid = Grid(grid)
    for block in chain(grid.iter_blocks(), grid.iter_rows(), grid.iter_cols()):
        if not is_valid_block(block):
            return False
    return True

if __name__ == '__main__':
    print is_valid_solution("751843926893625174642179583425316798176982345938754612364297851289531467517468239")
    print is_valid_solution("751843927893625174642179583425316798176982345938754612364297851289531467517468239")
    print is_valid_solution("571843926893625174642179583425316798176982345938754612364297851289531467517468239")
    print is_valid_solution("851743926693825174142679583425316798976182345738954612364297851289531467517468239")
