package main

import "testing"

func TestDay6(t *testing.T) {
	tests := []struct {
		marker string
		want   int
	}{
		{"bvwbjplbgvbhsrlpgdmjqwftvncz", 5},
		{"nppdvjthqldpwncqszvftbrmjlhg", 6},
		{"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10},
		{"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11},
	}
	for _, tc := range tests {
		ans := StartOfPacketMarker(tc.marker)
		if ans != tc.want {
			t.Logf("want %v but got %v", tc.want, ans)
			t.Fail()
		}
	}

	tests = []struct {
		marker string
		want   int
	}{
		{"mjqjpqmgbljsphdztnvjfqwrcgsmlb", 19},
		{"bvwbjplbgvbhsrlpgdmjqwftvncz", 23},
		{"nppdvjthqldpwncqszvftbrmjlhg", 23},
		{"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 29},
		{"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 26},
	}
	for _, tc := range tests {
		ans := StartOfMessageMarker(tc.marker)
		if ans != tc.want {
			t.Logf("want %v but got %v", tc.want, ans)
			t.Fail()
		}
	}
}
