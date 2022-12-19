package main

import "testing"

func TestDay9Part1(t *testing.T) {
	input := `R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2`
	ans := RunDay9Part1(input)
	if ans != 13 {
		t.Logf("want 13 but got %v", ans)
		t.Fail()
	}
}

func TestDay9Part2(t *testing.T) {
	input := `R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20`
	ans := RunDay9Part2(input)
	if ans != 36 {
		t.Logf("want 36 but got %v", ans)
		t.Fail()
	}
}
