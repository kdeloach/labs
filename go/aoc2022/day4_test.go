package main

import "testing"

func TestDay4(t *testing.T) {
	input := `2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8`
	ans := TotalAssignmentPairsContains(input)
	if ans != 2 {
		t.Logf("want 2 but got %v", ans)
		t.Fail()
	}
	ans = TotalAssignmentPairsOverlaps(input)
	if ans != 4 {
		t.Logf("want 4 but got %v", ans)
		t.Fail()
	}
}
