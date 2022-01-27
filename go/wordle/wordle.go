package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"sort"
	"strings"
	"syscall"
)

var fClues = flag.String("clues", "", "Comma separated list of clues. (ex. \"arose:G-Y--,allot:G--Y-\")")

func main() {
	signal.Ignore(syscall.SIGPIPE)
	flag.Parse()
	words := loadWords()
	clues := parseClues(*fClues)
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

var (
	NotSet byte = ' '
	Green  byte = 'g'
	Yellow byte = 'y'
)

type Clues struct {
	allMatch      map[byte]bool
	allMatchExact []byte
	noMatch       map[byte]bool
	noMatchExact  map[byte][]bool
}

// Parse clues CSV format "word:result,word:result,..."
func parseClues(cluesCsv string) *Clues {
	clues := &Clues{
		allMatch:      map[byte]bool{},
		allMatchExact: []byte{NotSet, NotSet, NotSet, NotSet, NotSet},
		noMatch:       map[byte]bool{},
		noMatchExact:  map[byte][]bool{},
	}

	if len(cluesCsv) == 0 {
		return clues
	}

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
			if c == Green {
				// character match (exact position)
				if clues.allMatchExact[i] == NotSet {
					clues.allMatchExact[i] = w[i]
				} else if clues.allMatchExact[i] != w[i] {
					fmt.Printf(fmt.Sprintf("conflict: multiple exact matches at position %v\n", i+1))
					os.Exit(1)
				}
			} else if c == Yellow {
				// character match (any position)
				clues.allMatch[w[i]] = true

				// character no match (exact position)
				if _, ok := clues.noMatchExact[w[i]]; !ok {
					clues.noMatchExact[w[i]] = []bool{false, false, false, false, false}
				}
				clues.noMatchExact[w[i]][i] = true
			} else if c == '?' {
				// unknown character match
				continue
			} else if c == '_' || c == '-' || c == ' ' {
				// characted no match (any position)
				clues.noMatch[w[i]] = true
			} else {
				fmt.Printf(fmt.Sprintf("invalid clue format: unexpected character \"%v\" (must be G, Y, -, _, ?, or space) \n", string(c)))
				os.Exit(1)
			}
		}

	}

	return clues
}

func isAlpha(c byte) bool {
	return c >= 'a' && c <= 'z'
}

type FilterFunc func(word string) bool

func createFilterFunc(clues *Clues) FilterFunc {
	return func(word string) bool {
		// handle no match (any)
		for c, _ := range clues.noMatch {
			if strings.IndexByte(word, c) != -1 {
				return true
			}
		}

		// handle all match (exact)
		for i := 0; i < 5; i++ {
			c := clues.allMatchExact[i]
			if isAlpha(c) && word[i] != c {
				return true
			}
		}

		// handle all match (any)
		for c, _ := range clues.allMatch {
			if strings.IndexByte(word, c) == -1 {
				return true
			}
		}

		// handle no match (exact)
		for i := 0; i < 5; i++ {
			if spots, ok := clues.noMatchExact[word[i]]; ok {
				if spots[i] {
					return true
				}
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
