package main

import "testing"

func TestDay8(t *testing.T) {
	input := `30373
25512
65332
33549
35390`
	ans := RunDay8Part1(input)
	if ans != 21 {
		t.Logf("want 21 but got %v", ans)
		t.Fail()
	}
	ans = RunDay8Part2(input)
	if ans != 8 {
		t.Logf("want 8 but got %v", ans)
		t.Fail()
	}
}
