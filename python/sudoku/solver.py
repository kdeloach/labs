from math import floor

ONE_TO_NINE = set([1, 2, 3, 4, 5, 6, 7, 8, 9])

def solve(puzzle, i=0):
    x = i % 9
    y = i / 9

    if y == 9:
        return True

    # This cell is already solved
    if puzzle[y][x] > 0:
        return solve(puzzle, i + 1)

    for n in possible_choices(puzzle, x, y):
        puzzle[y][x] = n
        if solve(puzzle, i + 1):
            return True
        else:
            puzzle[y][x] = 0

    return False


def possible_choices(puzzle, x, y):
    # Check along X axis
    result = [puzzle[y][x2] for x2 in range(9)]
    # Check along Y axis
    result += [puzzle[y2][x] for y2 in range(9)]
    # Check existing values within 3x3 grid
    gx, gy = grid_upperleft_xy(x, y)
    for i in range(3):
        result += puzzle[gy + i][gx:gx + 3]
    return ONE_TO_NINE - set(result)


# Return (x, y) tuple of first cell in a 3x3 grid.
# For the upper left 3x3 grid this should return (0, 0)
# For the lower right 3x3 grid this should return (6, 6)
def grid_upperleft_xy(x, y):
    return ((x / 3) * 3, (y / 3) * 3)


def display(puzzle):
    result = ""
    for y, row in enumerate(puzzle):
        if y > 0 and y % 3 == 0:
            result += "-----------\n"
        for x, n in enumerate(row):
            if x > 0 and x % 3 == 0:
                result += "|"
            result += str(n)
        result += "\n"
    return result


if __name__ == '__main__':
    _ = 0
    puzzle = [
        [_, _, _,  3, _, 8,  _, 9, _],
        [_, _, _,  _, 6, _,  _, 4, _],
        [_, _, _,  _, _, 4,  3, 5, _],
        [_, _, 6,  4, 5, _,  8, _, 2],
        [5, _, _,  _, _, _,  _, _, 9],
        [9, _, 4,  _, 1, 3,  5, _, _],
        [_, 7, 9,  8, _, _,  _, _, _],
        [_, 5, _,  _, 3, _,  _, _, _],
        [_, 1, _,  6, _, 7,  _, _, _]
    ]
    if solve(puzzle):
        print display(puzzle)
    else:
        print 'Failed to solve!'
