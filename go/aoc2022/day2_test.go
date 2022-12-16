package main

import "testing"

func TestDay2(t *testing.T) {
	input := `A Y
B X
C Z`
	ans := PlayRPS(input)
	if ans != 15 {
		t.Logf("want 15 but got %v", ans)
		t.Fail()
	}
	ans = PlayRPS2(input)
	if ans != 12 {
		t.Logf("want 12 but got %v", ans)
		t.Fail()
	}
}
