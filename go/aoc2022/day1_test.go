package main

import "testing"

func TestDay1(t *testing.T) {
	input := `1000
2000
3000

4000

5000
6000

7000
8000
9000

10000`
	ans := MostCalories(input)
	if ans != 24000 {
		t.Logf("want 24000 but got %v", ans)
		t.Fail()
	}
}
