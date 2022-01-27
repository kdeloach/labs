package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"regexp"
	"sort"
	"strings"
	"syscall"
)

var fClues = flag.String("clues", "", "Comma separated list of clues. (ex. \"arose:G-Y--,allot:G--Y-\")")
var fDebug = flag.Bool("debug", false, "Debug mode")

func main() {
	signal.Ignore(syscall.SIGPIPE)
	flag.Parse()
	words := loadWords()
	clues := parseClues(*fClues, *fDebug)
	filter := createFilterFunc(clues)
	words = filterWords(words, filter)
	rankWords(words)
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

// Parse clues CSV format "word:result,word:result,..."
func parseClues(cluesCsv string, debug bool) []string {
	regexes := []string{}

	if len(cluesCsv) == 0 {
		return regexes
	}

	allMatchExact := []byte{'.', '.', '.', '.', '.'}
	noMatch := map[byte]bool{}

	// parse "word:result,word:result,..."
	cluesSet := strings.Split(strings.ToLower(cluesCsv), ",")

	for _, wr := range cluesSet {
		// parse "word:result"
		pair := strings.Split(wr, ":")
		if len(pair) != 2 {
			fmt.Printf("invalid clue format\n")
			os.Exit(1)
		}

		w := pair[0]
		r := pair[1]
		if len(w) != len(r) {
			fmt.Printf("invalid clue format: word and result length mismatch\n")
			os.Exit(1)
		}

		if len(w) != 5 || len(r) != 5 {
			fmt.Printf("invalid clue format: word length must be 5 characters\n")
			os.Exit(1)
		}

		// parse clue string and compare to guess word
		// G = right letter right spot (green)
		// Y = right letter wrong spot (yellow)
		// everything else = wrong letter
		for i := 0; i < 5; i++ {
			c := r[i]
			if c == 'g' {
				// character match (exact position)
				allMatchExact[i] = w[i]
			} else if c == 'y' {
				// character match (any position)
				// character no match (exact position)

				anyMatches := []string{}
				for j := 0; j < 5; j++ {
					if j == i {
						continue
					}
					anyMatch := []string{".", ".", ".", ".", "."}
					anyMatch[i] = fmt.Sprintf("[^%v]", string(w[i]))
					anyMatch[j] = fmt.Sprintf("[%v]", string(w[i]))
					anyMatches = append(anyMatches, strings.Join(anyMatch, ""))
				}
				regexes = append(regexes, strings.Join(anyMatches, "|"))
			} else if c == '?' {
				// unknown character match
				continue
			} else if c == '_' || c == '-' || c == ' ' {
				// characted no match (any position)
				noMatch[w[i]] = true
			} else {
				fmt.Printf(fmt.Sprintf("invalid clue format: unexpected character \"%v\" (must be G, Y, -, _, ?, or space) \n", string(c)))
				os.Exit(1)
			}
		}

	}

	keys := []string{}
	for k := range noMatch {
		keys = append(keys, string(k))
	}
	regexes = append(regexes, fmt.Sprintf("[^%v]+", strings.Join(keys, "")))

	vals := []string{}
	for _, v := range allMatchExact {
		vals = append(vals, string(v))
	}
	regexes = append(regexes, strings.Join(vals, ""))

	if debug {
		fmt.Printf("Regexes:\n")
		for _, r := range regexes {
			fmt.Printf("%v\n", r)
		}
		fmt.Printf("---\n")
	}

	return regexes
}

func isAlpha(c byte) bool {
	return c >= 'a' && c <= 'z'
}

type FilterFunc func(word string) bool

func createFilterFunc(regexes []string) FilterFunc {
	rs := []*regexp.Regexp{}

	for _, reStr := range regexes {
		re := regexp.MustCompile(reStr)
		rs = append(rs, re)
	}

	return func(word string) bool {
		for _, re := range rs {
			match := re.FindString(word)
			if len(match) < 5 {
				return true
			}

		}
		return false
	}
}

func filterWords(words []string, skipWord FilterFunc) []string {
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

func rankWords(words []string) {
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
