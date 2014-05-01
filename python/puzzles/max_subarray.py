
"""Given an array of integers (positive or negative) find the contiguous sub-array with the largest sum."""

def max_subarray(nums):
    if len(nums) <= 0:
        return []
    ending_here = nums.pop(0)
    so_far = ending_here
    start_index = 0
    end_index = 0
    for i in xrange(1, len(nums)):
        n = nums[i]
        if n > ending_here + n:
            ending_here = n
            start_index = i
        else:
            ending_here += n
        if ending_here >= so_far:
            so_far = ending_here
            end_index = i
    return nums[start_index:end_index + 1]

def test():
    assert max_subarray([-2, 1, -3, 4, -1, 2, 1, -5, 4]) == [4, -1, 2, 1]
    assert max_subarray([13, -3, -25, 20, -3, -16, -23, 18, 20, -7, 12, -5, -22, 15, -4, 7]) == [18, 20, -7, 12]

if __name__ == '__main__':
    test()
