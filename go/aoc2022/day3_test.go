package main

import "testing"

func TestDay3(t *testing.T) {
	input := `vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw`
	ans := TotalSharedRucksackItems(input)
	if ans != 157 {
		t.Logf("want 157 but got %v", ans)
		t.Fail()
	}
	ans = TotalSharedRucksackBadges(input)
	if ans != 70 {
		t.Logf("want 70 but got %v", ans)
		t.Fail()
	}
}
