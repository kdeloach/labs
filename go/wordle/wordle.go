package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"sort"
	"strings"
)

var fAllMatch = flag.String("allMatch", "", "Right letters right spot. (ex. \"pi--a\")")
var fAnyMatch = flag.String("anyMatch", "", "Right letters wrong spot. Comma delimited list. (ex. \"-a---,co---\")")
var fNoMatch = flag.String("noMatch", "", "Wrong letters. (ex. \"xyz\")")
var fFindBest = flag.Bool("best", false, "Find best word from filtered set.")

func main() {
	flag.Parse()
	words := loadWords()
	words = filterWords(words, *fAllMatch, *fNoMatch, *fAnyMatch)
	if *fFindBest {
		bestWord(words)
	} else {
		for _, w := range words {
			fmt.Println(w)
		}
	}
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

func filterWords(words []string, allMatch, noMatch, anyMatchCsv string) []string {
	skipWord := func(string) bool { return false }

	anyMatchSet := []string{}
	anyMatch := ""

	if len(anyMatchCsv) > 0 {
		anyMatchSet = strings.Split(anyMatchCsv, ",")
		for _, c := range anyMatchCsv {
			if c >= 'a' && c <= 'z' {
				anyMatch += string(c)
			}
		}
	}

	if noMatch != "" {
		oldSkipWord := skipWord
		skipWord = func(word string) bool {
			if strings.ContainsAny(word, noMatch) {
				return true
			}
			return oldSkipWord(word)
		}
	}
	if anyMatch != "" {
		oldSkipWord := skipWord
		skipWord = func(word string) bool {
			for _, c := range anyMatch {
				if strings.Index(word, string(c)) == -1 {
					return true
				}
			}
			return oldSkipWord(word)
		}
	}
	if len(anyMatchSet) > 0 {
		oldSkipWord := skipWord
		skipWord = func(word string) bool {
			for _, w := range anyMatchSet {
				for i := 0; i < len(w); i++ {
					c := w[i]
					if c >= 'a' && c <= 'z' {
						if word[i] == c {
							return true
						}
					}
				}
			}
			return oldSkipWord(word)
		}
	}
	if allMatch != "" {
		oldSkipWord := skipWord
		skipWord = func(word string) bool {
			l := len(allMatch)
			if len(word) < l {
				l = len(word)
			}
			for i := 0; i < l; i++ {
				c := allMatch[i]
				if c >= 'a' && c <= 'z' {
					if word[i] != c {
						return true
					}
				}
			}
			return oldSkipWord(word)
		}
	}

	newWords := []string{}
	for _, w := range words {
		if skipWord(w) {
			continue
		}
		newWords = append(newWords, w)
	}
	return newWords
}

type record struct {
	word string
	wins float64
	rank float64
}

func bestWord(words []string) {
	records := make([]*record, len(words))

	for i, w := range words {
		records[i] = &record{
			word: w,
		}
	}

	var total float64

	for _, w := range words {
		for _, r := range records {
			if w == r.word {
				continue
			}
			s := score(w, r.word)
			total += s
			if s > 0 {
				r.wins += s
			}
		}
	}

	// normalize
	for _, r := range records {
		r.rank = r.wins / total
	}

	sort.Slice(records, func(i, j int) bool {
		return records[i].rank > records[j].rank
	})

	if len(records) == 0 {
		fmt.Println("No solution")
	} else if len(records) == 1 {
		fmt.Println(records[0].word)
	} else {
		for _, r := range records {
			fmt.Printf("%v %.2f%%\n", r.word, r.rank*100)
		}
	}
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
