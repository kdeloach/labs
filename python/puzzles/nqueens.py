
def solve(board, rank=0):
    if rank >= board.size:
        return board
    for spot in board.valid_rank_spots(rank):
        board.append(spot)
        if solve(board, rank + 1):
            return board
        board.pop()
    return False

class Board(list):

    def __init__(self, size, piece):
        self.size = size
        self.piece = piece
        self.offsets = piece.offsets(size)

    def valid_rank_spots(self, rank):
        for i in xrange(self.size):
            xy = (i, rank)
            if not self.is_conflict(xy):
                yield xy

    def is_conflict(self, xy):
        x, y = xy
        valid_offsets = [
            (ox, oy) for ox, oy in self.offsets
            if y + oy >= 0 and x + ox >= 0 and x + ox < self.size
        ]
        return any((x + ox, y + oy) in self for ox, oy in valid_offsets)

    def __str__(self):
        result = []
        for i in xrange(self.size ** 2):
            x = i % self.size
            y = i / self.size
            if (x, y) in self:
                result.append(str(self.piece))
            else:
                result.append('_')
            result.append('|')
            if x == self.size - 1:
                result.append('\n')
        return ''.join(result)


class Queen(object):

    def offsets(self, board_size):
        offset0 = [(0, -i) for i in xrange(1, board_size)]
        offset1 = [(-i, -i) for i in xrange(1, board_size)]
        offset2 = [(i, -i) for i in xrange(1, board_size)]
        return offset0 + offset1 + offset2

    def __str__(self):
        return 'Q'


class Rook(object):

    def offsets(self, board_size):
        offset0 = [(0, -i) for i in xrange(1, board_size)]
        return offset0

    def __str__(self):
        return 'R'


class KingLikeRook(object):
    """Rook that also moves like a King"""

    def offsets(self, board_size):
        offset0 = [(0, -i) for i in xrange(1, board_size)]
        return offset0 + [(-1, -1), (1, -1)]

    def __str__(self):
        return 'R'

if __name__ == '__main__':
    print solve(Board(4, Rook()))
    print solve(Board(8, KingLikeRook()))
    print solve(Board(12, Queen()))
