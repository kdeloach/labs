package main

import (
	"strings"
)

func PlayRPS(input string) int {
	total := 0
	lines := strings.Split(input, "\n")
	for _, line := range lines {
		moves := strings.Split(line, " ")
		me := ParseRPS(moves[1])
		them := ParseRPS(moves[0])
		total += ScoreRPS(me, them)
	}
	return total
}

func PlayRPS2(input string) int {
	total := 0
	lines := strings.Split(input, "\n")
	for _, line := range lines {
		moves := strings.Split(line, " ")
		them := ParseRPS(moves[0])
		me := ParseRPS2(them, moves[1])
		total += ScoreRPS(me, them)
	}
	return total
}

func ParseRPS(shape string) string {
	if shape == "A" || shape == "X" {
		return "R"
	}
	if shape == "B" || shape == "Y" {
		return "P"
	}
	if shape == "C" || shape == "Z" {
		return "S"
	}
	panic("error parsing RPS shape: " + shape)
}

func ParseRPS2(them, result string) string {
	if result == "Y" {
		return them
	}
	if result == "X" {
		return ShapeLosesTo(them)
	}
	if result == "Z" {
		return ShapeLosesTo(ShapeLosesTo(them))
	}
	panic("unknown result: " + result)
}

func ShapeLosesTo(shape string) string {
	if shape == "R" {
		return "S"
	}
	if shape == "P" {
		return "R"
	}
	if shape == "S" {
		return "P"
	}
	panic("unknown shape: " + shape)
}

func ScoreRPS(me, them string) int {
	score := 0
	if me == "R" {
		score = 1
	} else if me == "P" {
		score = 2
	} else if me == "S" {
		score = 3
	}

	if me == them {
		score += 3
	} else if ShapeLosesTo(me) == them {
		score += 6
	} else {
		score += 0
	}

	return score
}

const Day2Input = `A Y
B X
C X
A Z
B Y
C X
C X
C X
C X
C X
A Z
B Y
C X
A Z
A Z
B Y
A Z
B X
C Z
C X
C X
B Y
C X
A X
B Y
B Z
A Z
B Y
C X
C X
C X
A Z
B Y
C X
A Z
C X
B Y
C X
C X
B Y
A Z
A Z
C X
C X
A Y
B X
C X
B X
C X
C X
A Z
C Z
C X
A Y
B Y
B Y
B X
C X
C X
C X
A Y
A Z
C X
A Z
C X
B Y
C X
C X
C X
C X
A Z
C X
A Z
C X
C X
B Y
C X
B Y
A X
A Y
C Y
A Z
C X
C X
A X
A Z
A X
C X
C X
A X
C X
B Y
A Z
A Y
A Z
B X
C X
B X
C X
C X
A Z
C X
C Z
C X
C X
C X
C X
C X
A Z
A X
C X
A Z
C X
C X
A Z
C X
A Z
A Y
C X
C X
A Z
A Z
C X
C X
A Z
A Z
C Z
C X
A Z
A Z
C X
B Y
C X
C X
A Y
A Z
A Z
A Z
A Y
B Y
A Z
C X
A Y
A Z
A Y
A Z
C X
C X
C X
B X
B Y
A Z
A Z
A Z
C X
A Z
A X
B X
C X
C X
C X
A Z
A Z
A Z
C X
C X
A X
A Z
C Y
A Z
C X
C X
C Z
C X
A Z
A X
C Y
A X
C X
C X
C X
A X
A X
C X
A Z
A Z
A Z
A Z
A Z
A Y
C X
A Z
A Z
A Z
B Y
C X
C X
A X
B X
A Z
C X
A Z
C X
A Z
C X
A Z
A Y
C X
C X
C X
A Y
C X
C Y
C Z
C X
C X
B Y
C X
A Z
C Z
A Z
C X
A Y
B Y
C X
C X
C X
B X
A Z
C X
C X
C X
B X
A Z
A Z
C X
C X
C X
A Z
A X
B Y
C Y
C X
A Z
A Z
A Z
B Y
B X
C X
A Z
A Y
B Z
C X
C X
A Z
A X
C X
A Z
B Y
A Z
C Z
B X
A Z
C X
C X
C X
A Y
C X
C X
A Z
A X
C Z
A Y
C X
C X
A Y
A X
B Y
C X
C X
C X
A Z
A X
C X
A X
A X
C X
C X
A Z
C X
A Z
A X
A Z
C X
B Y
A Z
C X
A Z
A X
B X
C X
B Y
A Y
A Y
C Z
B Z
C X
C X
C X
A Z
C Z
A Y
C X
A Y
C Z
A Y
B Y
C X
C X
A Z
B Y
C X
A Z
C X
C X
A Z
B Y
C X
B Y
C X
B Y
A Y
C X
A X
A X
B X
C X
A Z
C X
B Y
A Y
C X
B Y
B X
C X
C X
A Z
B X
A X
C X
C X
B Y
C Z
B X
C X
A Z
A Z
A X
C X
A Z
C X
A Z
C X
A Z
C X
A Z
A Y
A Y
C Z
C X
A X
C X
A Z
C X
B X
A Z
A Y
A Z
C X
A Z
C X
B Y
A X
C X
A Y
C X
C X
C X
A Z
A Y
C X
A X
C X
A Z
C X
C X
A Y
C X
C X
C X
A Z
A Z
C X
A Z
B X
A Z
C X
B Y
B X
C X
B Y
A Z
A X
C X
A Y
A X
A Z
B Y
A X
C X
C X
C X
C X
A Z
C X
C X
A X
A Z
A Z
B Y
A Z
A X
A Z
C X
B X
A Y
A X
A Y
C X
A Z
C X
A Z
B X
A Y
C X
C X
A Z
A Z
C X
C Y
A Z
A Z
A Z
A Y
C X
C X
A Z
A Z
A Z
B Y
C X
A Z
C X
A Y
A Z
A Z
A Z
C X
A X
A Z
A Z
B Y
B X
A Z
A X
C X
C X
A Z
A Z
C X
A X
A Z
C X
A X
C X
A Z
A Y
C X
B Y
B Y
C X
C X
C X
C X
C X
A X
A X
A Y
A Z
A X
C X
A X
A Z
B Y
A X
A X
C X
A Z
C X
C X
C X
A Z
A X
A X
C X
C X
C X
C X
C X
C X
A Z
C X
C X
C Z
C X
A Z
A Z
C X
C X
A Z
A Z
C X
A Z
A Z
A Z
A Z
C X
A X
C X
B Y
C X
A X
A X
A Y
C X
A Y
A Z
C X
C X
C Z
C X
C X
C X
B X
C X
C X
C X
A Y
C X
C X
A Z
C X
A Y
C X
C Z
C X
C X
B X
A Z
C X
C X
C X
C X
C X
B X
A Z
C X
A Z
B X
B Y
B Y
C X
C X
C Y
A Z
C X
C X
A X
A X
A X
A X
C X
C X
C X
C X
A Z
C X
A Z
A X
C X
C X
B Y
B Y
A Z
C X
A X
A Z
A Z
B Y
C X
C X
A Z
C X
A Z
C X
B X
C X
A Y
C X
C X
A X
B Y
B Y
C Z
C X
C X
B Y
A X
C X
C X
A X
A Z
C X
C X
A Z
B Y
A Z
C X
C X
A X
A X
C X
C Z
C X
A Z
B X
C X
B Y
A Y
B X
A Z
A Z
A X
A Z
A Y
A Z
A X
A Z
C X
C X
A Z
B Y
A Z
B X
B Y
A Z
C X
C Y
A Z
C X
C X
A X
A Z
A X
C X
C X
A Z
C X
C X
C X
C X
A X
B X
A Z
A Z
C X
A X
A X
C X
C X
A Z
A Z
C X
C X
A X
A Z
C X
A X
A Z
A Z
C X
A Z
A Z
C X
C X
A Z
C X
C X
A Z
C X
C X
A Z
A X
C X
C X
A Z
A Z
C X
C X
C X
A Y
C X
C X
B Y
C X
C X
C X
C X
A Z
A Z
A X
C X
A X
C X
A Z
B X
A Z
C X
C X
A Z
A Y
C X
C X
A Z
C X
B X
B X
B Y
A Y
A Y
A Z
A Z
A Z
C X
C X
A Z
C X
B Y
C X
B Z
A Z
C X
A Z
C X
C X
C X
C X
A Z
B X
A Y
C X
A X
A Z
B Y
A X
C X
C X
C X
C X
C X
A Z
A X
A Z
A X
A Z
A Z
C X
A X
C X
B X
C Z
A X
B X
A Y
C X
A Z
A Z
B X
B Y
B Y
C X
A Z
A X
C X
C X
B Z
B X
B Y
A Z
B Y
A Z
C X
A Z
A X
A Z
C X
C X
C X
A X
C X
A Z
C X
C X
C Y
B X
C X
A X
C X
A X
A Z
C Z
A Z
C X
A Y
C X
C X
B Y
C X
C X
A Z
C X
C X
C X
A Z
C Y
C X
A X
A Z
A X
C X
A Z
A Z
B Y
B X
A Z
C X
A Z
C X
A X
C X
C Y
A Z
A Y
C Z
C X
C Z
A Z
A Z
C X
C X
A Y
A X
B Y
C X
A Y
C X
A Y
C X
A Z
B X
A Y
C X
B X
A Z
C X
A Z
A Z
A Y
A Z
A X
B Y
C X
C X
C X
A Z
A X
C X
A Y
A Y
C X
A Z
C X
C Y
C X
C X
A X
A Z
A X
A X
C X
A X
A Z
C X
A Y
A Y
C X
B Y
A Y
C X
A Z
A Z
A X
C X
A Y
C X
C X
C X
C X
A Y
A Z
B Y
A X
A Y
C X
C X
C X
B X
A Z
C X
C X
B X
A Z
A X
C X
A X
C X
B Y
A Z
C X
C X
B X
A Z
A Z
A Z
C X
C X
C X
C Y
C X
C X
A Z
C X
A Z
C X
C X
B X
A X
A Z
C X
B Z
C X
C X
A X
A Y
C X
A Z
A Z
C X
C X
C X
C X
C X
C X
B Y
A Z
C X
A X
A Z
A Z
C X
C X
C X
A Z
C X
B Y
A Z
A Z
C X
C X
C X
C X
A Z
C X
A Z
A Y
A X
C X
A Z
C X
C X
A Z
A Z
A X
A Z
C X
A Z
A X
A Z
C X
C X
C Z
A X
C X
C X
A X
A X
C X
A Z
A Z
A Z
C X
C X
A Z
B Z
A Z
A Z
C X
A Z
C X
A Z
B X
C X
A Z
B Y
B Y
C X
A X
A Z
C X
C X
A Z
C Y
B Y
A Z
C X
C X
A Z
A Z
C Z
A Z
C X
C X
A Y
C X
A Y
B X
C Z
C X
A Y
C X
B Y
C X
C X
C Z
A Z
A Z
C X
C X
A Z
B Z
C X
A Z
C X
A Z
C X
C X
C Y
C X
B Y
A X
A Z
C X
B Y
A Z
B Y
C X
C Y
C Z
A X
A Z
A X
C X
C X
A Z
A Z
C X
C X
C X
C X
B Y
B Y
A Y
C X
C X
C X
A X
C X
B Y
A Z
B Y
C X
C X
B Y
C X
B Y
C X
C X
C X
A Z
A Z
C X
C X
B Z
A X
C X
C X
A Z
C X
C X
C X
C X
A Z
C X
A Y
A Z
C X
A Z
A Y
C X
A X
C Y
A Y
A Y
C X
C X
A X
A Y
C X
B Y
A Z
B Y
C X
B X
C X
C X
C X
B Z
A Y
C X
B Y
C X
A X
C X
C X
B X
A Z
C X
A Z
C X
C X
C X
C X
C X
C X
A X
A Z
A Z
C X
C X
C Z
B X
C Z
C X
B X
C X
A Z
B Y
A Z
C Z
C X
B X
A X
A Z
C X
C X
A Z
A Z
A Z
A X
C X
C X
A Y
A Z
C X
A Z
B Y
C X
C Z
A Z
C X
C X
C X
A X
A Z
A Z
C X
A Y
A Y
C X
C X
C X
C X
C X
A Z
C X
B X
C X
B X
B Y
A Z
C X
B Y
A Y
C Z
A Z
A X
C X
A Z
C X
A Z
C Z
C X
C X
A Z
C X
C X
C X
B Y
A Z
B X
A Z
A Z
B X
A X
A Z
C X
C X
A Y
C X
A Z
B Y
C Y
A Z
C Y
C X
A Z
C X
C X
A X
C X
A X
A Z
B Y
B Y
C X
B Y
C Z
C X
C X
B Y
A Z
C X
C X
C X
C X
C X
A X
A Z
B Y
A Y
C X
C X
C Z
C X
A X
C X
A Z
B Y
A Z
B X
C X
C X
A Z
C X
A Y
A Y
C X
B X
C X
B X
A Y
A Z
A Z
C X
A Z
A X
A Z
C X
C X
C X
A Z
B X
B X
A Z
C X
B Y
C X
C X
A Z
A X
C X
B Y
C X
C X
C X
A X
A X
B Y
A Y
A X
C X
A Z
B X
A Z
B Y
C X
B Y
A Y
C X
C X
C X
A Y
A Z
A Z
A X
A Z
A X
C X
A Z
A Y
A Z
A Z
A Z
A X
A Z
A Z
C X
C X
C X
A Z
C X
C X
B Y
C X
C X
C X
C Y
A Z
A Z
A Z
C X
A Z
B X
A X
A Z
A Y
C X
A Z
C X
A Z
A Y
B Y
C X
A X
A Z
A Z
C Y
A X
B Y
B Y
C X
A Z
A Z
A Z
A Z
A Z
A Z
A Z
C X
C X
B Y
C X
C X
A Y
C X
A Z
C X
A X
C X
A X
C X
C X
B X
C X
B X
C X
C X
A Y
A X
A Z
C X
A X
A Y
A Z
C X
C X
C X
B Y
A Z
A Y
A Z
C X
A Y
B X
C X
A X
A Y
A Y
A Z
A Z
A Z
C X
A Z
A X
A Z
C X
B X
A Z
C X
C X
A X
A Z
A Z
B Y
A Z
A X
A Z
A Z
A Z
A X
B Y
A X
A Z
C X
B X
A Z
A Z
A Y
B Y
A Y
B Y
C X
C X
A Z
B Y
A Z
A X
A Z
A Z
C X
C X
A Z
A X
C X
B Y
C X
C X
C X
C Z
A Y
C X
A Y
A Y
A Y
A Z
A X
A Z
A X
A Z
B Y
C X
A Z
A Y
C X
B Y
A Z
B Y
C X
B X
B Y
C X
A Z
B X
C X
B Y
B Y
C X
C X
A Z
B X
A X
A Z
C X
A Z
C X
C X
A Z
B X
A Z
C Y
C X
A Z
A X
B Y
B Y
C Y
B Y
A Y
C X
A X
C X
C X
C X
A Y
A Z
B Y
A Z
A Y
C X
A Y
A Y
A Y
C X
B X
B X
C X
B X
C X
C X
A X
A X
A X
C X
C X
C Y
A Y
A Z
C X
B Y
C X
A X
C X
A Z
C X
C X
C X
B X
C X
C Z
A Z
C Y
B Y
A Y
A Z
A Z
A X
A Y
C X
C Y
C X
C X
A X
A Y
A Z
C X
B X
B Y
B Y
C X
C X
C X
C X
A Z
C X
C X
B Y
C X
C X
A Z
A Z
A Z
A X
A Y
A Z
C Z
A Z
C X
C X
B Y
A X
C X
A Z
C X
A X
C X
A Z
C X
C X
A Z
A X
C X
C X
C X
A Y
C X
C X
A Z
C X
A Z
C X
A Z
C X
C X
C X
C X
A Z
C X
A Z
C X
A Z
A Z
B Z
A Z
A Y
C X
B X
C X
C X
C Z
C X
C X
C X
A X
A Z
A Z
A Z
C X
C X
C X
A Z
B Y
C X
C X
C X
A Z
C X
A Y
C X
B Y
A Z
C X
B X
C X
A X
C X
C X
C X
A Z
A Z
A Z
B Z
C X
A Z
A X
C X
B X
A X
A Y
B Y
B Y
A Z
C X
C X
C X
C X
A Z
A Z
C X
A X
B Y
B Y
A Z
A Z
C X
C X
A Z
A Y
C X
A Y
A Z
A Y
C X
A Z
C X
A Z
B Y
A X
A Z
C X
A X
C X
A Z
C X
C X
A Z
B X
B X
A Z
C X
A Y
A Z
C X
A X
A X
A Z
A Y
C X
A Z
B Z
C X
A Z
C X
A Z
A Z
C X
A Z
B X
A Z
C X
A Z
A Z
C X
C X
A X
A Z
A Z
C X
A Z
C X
A Z
C X
A X
A Z
A Z
C Z
C X
C X
B Y
B Y
C X
C X
C X
B X
A X
C X
A X
B Y
C X
B Y
A Z
A Z
A Y
A Z
B X
A X
C X
B Y
C X
A Z
C X
C X
A Z
A X
C X
C X
A Z
B Y
C X
A Z
B Y
A Z
A Z
A X
C X
A Z
C X
B Y
C X
C X
C X
A X
B Y
C X
A X
C X
A Z
C X
C X
B X
B X
C X
C X
A Z
B X
C X
A X
C X
B Y
A Y
C Z
C X
A Z
C Z
B Y
B Y
A Z
C Z
C X
C X
C X
A X
C X
A Z
B X
A Z
B Y
A Z
B X
A X
A Z
A Z
C X
B X
C X
A Z
B Y
A Z
C X
A Z
A Z
A X
A Z
A X
A X
C X
B X
C X
C X
B Y
C X
C X
A X
C X
C X
C X
C X
C X
A Z
C X
C X
A Z
A Z
B Y
C X
C Z
C X
B Y
C X
C X
C X
A Z
A Y
A X
C X
C X
B Y
C Z
C X
A Y
B Y
C X
C X
A Z
A Z
C X
C X
C X
B X
C X
C X
C X
C X
B Y
A X
C X
C X
A Z
C X
C X
C X
A Z
C X
C X
B Y
C X
A Y
C X
A Z
A Z
B Y
C X
C Y
A Y
C X
B Y
A Z
B X
C X
C X
A X
C X
C X
C X
C X
A X
A X
A Z
C X
B Z
C X
A Y
A Z
A Z
C X
C X
C X
A Z
A Z
A X
A Z
A Z
A Z
A Y
A X
A Z
C X
B Y
C X
A Z
C X
C Z
B X
C X
C X
A Z
A X
B X
C X
A Z
A Z
A Z
C Z
C X
B Y
C X
C X
C X
A Z
B Y
C X
C X
C X
C X
C X
C X
A X
C Z
B Y
A X
A X
B X
C X
C X
C X
A Z
A Z
B X
C X
C X
A Z
C X
A Z
C X
C X
C X
C X
A Z
C Y
C X
C X
A Z
A Z
A Z
A Y
A X
A X
C X
A Z
B X
A Z
C X
B X
C X
A Y
A X
C X
C X
C X
B X
B X
C X
A Z
A Z
C X
C X
A Z
B X
A Z
A Y
A X
A Y
C X
A Z
B Y
C X
A Z
C X
C X
A Z
A Z
A Y
B X
A Z
C X
A X
A Z
A Z
A Z
A X
C X
A Z
A Z
B X
A Y
C X
C X
C X
C X
B X
B Y
C X
A Z
C X
B Y
B Y
C X
B X
A Z
C X
C X
A Z
B Y
C X
A Z
C X
C X
A Z
C X
A Z
A X
C X
C X
A X
A Z
C X
A X
C X
C X
A X
C X
A X
A Y
A Z
A Y
A Z
C X
A Z
A Z
B Z
A Y
A Z
C X
A Z
C X
A X
C X
C Y
C X
C X
C X
A Z
B X
C X
C X
A Z
A Z
C Z
C X
A X
A Y
B Y
A Z
A X
B X
C X
C X
C X
A Y
C X
A Z
C X
C X
A Z
A X
C X
C Z
C X
C X
C X
A Z
A Y
C X
C X
A Z
C X
C Y
C X
C X
A Z
A X
C X
B X
A Z
A Z
C X
A Z
A Z
C X
A Y
C Y
A Z
A Z
B X
C X
A Z
A Z
C X
C X
C X
B Y
A Z
B Y
C X
B X
A X
C X
A Z
A Y
C X
A Z
C Z
A X
C X
A Z
C X
C X
A Z
C X
A Y
C X
C X
A Y
C X
B X
C X
C X
B Y
A X
C X
A Y
B Y
C X
A X
A Z
C Z
A X
C X
C X
B X
A Z
B Z
A Z
A X
A Y
C X
A X
B X
C X
C X
C X
C X
A Z
C X
A Z
A Z
C X
B X
C X
A Y
A Z
A X
A X
C X
A Y
C X
C X
A Y
C X
B X
A Z
C X
A Z
B X
A Z
B Y
C X
C X
C X
A Z
C X
C X
A X
C X
A Z
C X
C X
A Z
C X
A X
B Y
A Y
C X
C X
C X
A X
C X
A Z
C X
A X
C X
C X
A Y
C X
C X
C X
C X
A Z
C X
C X
A Y
A Z
C X
C X
C X
A Z
A Z
C Z
A Y
C X
C X
B Z
B Y
B Y
B Y
C Z
B Y
A Z
B X
C X
A Z
A Y
C X
B Y
C X
A X
B X
A Z
A Z
C X
C Y
A Z
B Y
A Z
A Z
C X
C X
B Y
C X
A Z
C Z
A X
C X
C X
C X
A Z
C X
B X
B Y
C X
A Z
A Z
C X
A Z
C Z
C X
B X
A X
B Z
A Z
C X
A X
C X
C X
C X
C X
A Z
C X
C X
C X
C X
A Z
A Z
C X
C X
A X
A Z
C X
A X
C X
C Y
C X
A Z
B X
A Y
A Z
C Y
A Z
C X
A Y
C X
A X
C X
A X
C X
A Z
C X
A X
A Z
A X
A Y
C Z
C X
A X
A Z
A Z
A Z
A Z
C X
C X
C Z
A X
A Z
B Y
A Z
A Z
B X
B Y
A X
A Y
A Z
C X
A Z
C X
A Z
B X
B X
C X
C X
C X
A X
C X
A Z
B X
A Y
B X
C X
A X
C X
A X
A Z
A Z
A Z
C X
B Y
C X
B Y
C X
A Z
A Z
A Z
C X
C X
B Y
A Y
C Y
A Z
C X
C X
A Z
C X
A Z
C Z
B X
C X
C X
A Z
B Y
A Y
C X
A X`
