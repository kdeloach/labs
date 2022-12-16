package main

import "testing"

const Day5TestInput = `    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2`

func TestDay5Parse(t *testing.T) {
	n := ParseStacksCount(Day5TestInput)
	if n != 3 {
		t.Logf("want 3 but got %v", n)
		t.Fail()
	}
}

func TestDay5(t *testing.T) {
	ans := RunSupplyStacks(Day5TestInput)
	if ans != "CMZ" {
		t.Logf("want CMZ but got %v", ans)
		t.Fail()
	}

	ans = RunSupplyStacks2(Day5TestInput)
	if ans != "MCD" {
		t.Logf("want MCD but got %v", ans)
		t.Fail()
	}
}

func TestStack(t *testing.T) {
	s := Stack{}
	s.Push("a")
	s.Push("b")
	s.Push("c")
	if ans := s.Head(); ans != "c" {
		t.Logf("want c but got %v", ans)
		t.Fail()
	}
	if ans := s.Pop(); ans != "c" {
		t.Logf("want c but got %v", ans)
		t.Fail()
	}
	if ans := s.Head(); ans != "b" {
		t.Logf("want b but got %v", ans)
		t.Fail()
	}
}
