package main

import "testing"

func TestDay7(t *testing.T) {
	input := `$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k`
	ans := RunDay7Part1(input)
	if ans != 95437 {
		t.Logf("want 95437 but got %v", ans)
		t.Fail()
	}
	ans = RunDay7Part2(input)
	if ans != 24933642 {
		t.Logf("want 24933642 but got %v", ans)
		t.Fail()
	}
}

func TestStringIter(t *testing.T) {
	it := NewStringIter("A\nBC\nDEF")

	tests := []string{"A", "BC", "DEF"}
	for _, tc := range tests {
		v := it.Peek()
		if v != tc {
			t.Logf("want %v but got %v", tc, v)
			t.Fail()
		}
		v = it.Next()
		if v != tc {
			t.Logf("want %v but got %v", tc, v)
			t.Fail()
		}
	}
}
