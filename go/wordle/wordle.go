package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	words := loadWords()
	w1 := bestWord(words, "")
	w2 := bestWord(words, w1)
	w3 := bestWord(words, w1+w2)
	bestWord(words, w1+w2+w3)
}

func loadWords() []string {
	words := []string{}

	file, err := os.Open("wordle-answers-alphabetical.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		words = append(words, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}

	return words
}

func bestWord(words []string, excludeLetters string) string {
	wins := make([]float64, len(words))
	loss := make([]float64, len(words))

	for ai := 0; ai < len(words); ai++ {
		for gi := 0; gi < len(words); gi++ {
			if gi == ai {
				continue
			}
			if strings.ContainsAny(words[gi], excludeLetters) {
				continue
			}
			s := score(words[ai], words[gi])
			if s > 0 {
				wins[gi] += s
			} else {
				loss[gi] += 5
			}
		}
	}

	var bestIndex int = -1
	var bestScore float64 = -1

	for i := 0; i < len(words); i++ {
		score := wins[i] / loss[i]
		if score > bestScore {
			bestScore = score
			bestIndex = i
		}
	}
	if bestIndex == -1 {
		fmt.Printf("No solution\n")
		return ""
	}
	fmt.Printf("best: %v, win:loss = %v:%v\n", words[bestIndex], wins[bestIndex], loss[bestIndex])
	return words[bestIndex]
}

func score(a, b string) float64 {
	rightLetterRightSpot := 0
	rightLetterWrongSpot := 0

	for i, _ := range b {
		if a[i] == b[i] {
			a = a[:i] + "_" + a[i+1:]
			rightLetterRightSpot++
		}
	}

	for i, _ := range b {
		if k := strings.IndexByte(a, b[i]); k != -1 {
			a = a[:k] + "_" + a[k+1:]
			rightLetterWrongSpot++
		}
	}

	return float64(rightLetterRightSpot) + float64(rightLetterWrongSpot)*0.5
}
