package main

import (
	"strconv"
	"strings"
)

func RunDay10Part1(input string) int {
	x := 1
	cycle := 1
	sum := 0
	test := func() {
		if cycle == 20 || cycle == 60 || cycle == 100 || cycle == 140 || cycle == 180 || cycle == 220 {
			sum += cycle * x
		}
	}
	for _, line := range strings.Split(input, "\n") {
		if line != "noop" {
			parts := strings.Split(line, " ")
			n, err := strconv.Atoi(parts[1])
			if err != nil {
				panic(err)
			}
			cycle++
			test()
			x += n
		}
		cycle++
		test()
	}
	return sum
}

func RunDay10Part2(input string) string {
	x := 1
	cycle := 1
	output := ""
	render := func() {
		sx := (cycle-1)%40 + 1

		if x <= sx && sx <= x+2 {
			output += "#"
		} else {
			output += "."
		}

		if cycle%40 == 0 {
			output += "\n"
		}
	}
	for _, line := range strings.Split(input, "\n") {
		render()
		cycle++
		if line != "noop" {
			parts := strings.Split(line, " ")
			n, err := strconv.Atoi(parts[1])
			if err != nil {
				panic(err)
			}
			render()
			cycle++
			x += n
		}
	}
	return strings.TrimSuffix(output, "\n")
}

const Day10Input = `noop
noop
noop
addx 6
addx -1
addx 5
noop
noop
noop
addx 5
addx 11
addx -10
addx 4
noop
addx 5
noop
noop
noop
addx 1
noop
addx 4
addx 5
noop
noop
noop
addx -35
addx -2
addx 5
addx 2
addx 3
addx -2
addx 2
addx 5
addx 2
addx 3
addx -2
addx 2
addx 5
addx 2
addx 3
addx -28
addx 28
addx 5
addx 2
addx -9
addx 10
addx -38
noop
addx 3
addx 2
addx 7
noop
noop
addx -9
addx 10
addx 4
addx 2
addx 3
noop
noop
addx -2
addx 7
noop
noop
noop
addx 3
addx 5
addx 2
noop
noop
noop
addx -35
noop
noop
noop
addx 5
addx 2
noop
addx 3
noop
noop
noop
addx 5
addx 3
addx -2
addx 2
addx 5
addx 2
addx -25
noop
addx 30
noop
addx 1
noop
addx 2
noop
addx 3
addx -38
noop
addx 7
addx -2
addx 5
addx 2
addx -8
addx 13
addx -2
noop
addx 3
addx 2
addx 5
addx 2
addx -15
noop
addx 20
addx 3
noop
addx 2
addx -4
addx 5
addx -38
addx 8
noop
noop
noop
noop
noop
noop
addx 2
addx 17
addx -10
addx 3
noop
addx 2
addx 1
addx -16
addx 19
addx 2
noop
addx 2
addx 5
addx 2
noop
noop
noop
noop
noop
noop`
