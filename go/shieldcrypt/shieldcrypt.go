package main

import (
	"flag"
	"fmt"
	"math/rand"
	"os"
	"strings"

	"github.com/btcsuite/btcutil"
)

var nRandomSeedFlag = flag.Int64("s", 0, "random seed")
var nLettersFlag = flag.Int("n", 1, "number of letters to replace")

const Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

func main() {
	flag.Parse()

	wifOrig := "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"
	fmt.Printf("%v\n", wifOrig)

	wifPart := ""
	letters := ""
	indexes := []int{}

	for i := 0; i < len(wifOrig); i++ {
		c := string(wifOrig[i])
		if len(letters) < *nLettersFlag && !strings.Contains(letters, c) {
			wifPart = wifPart + "0"
			letters = letters + c
			indexes = append(indexes, i)
		} else {
			wifPart = wifPart + c
		}
	}

	fmt.Printf("%v\n", wifPart)
	fmt.Printf("%v (replaced %d letters)\n", letters, len(letters))

	letters = shuffle(letters)
	fmt.Printf("%v (scrambled)\n", letters)

	perm([]byte(letters), func(cs []byte) {
		wif2 := wifPart
		for i, c := range cs {
			j := indexes[i]
			wif2 = wif2[:j] + string(c) + wif2[j+1:]
		}

		_, err := btcutil.DecodeWIF(wif2)
		if err != nil {
			return
		}

		fmt.Printf("match found: %v\n", wif2)
		os.Exit(0)
	}, 0)

	fmt.Printf("no match found\n")
	os.Exit(1)
}

func perm(a []byte, f func([]byte), i int) {
	if i > len(a) {
		f(a)
		return
	}
	perm(a, f, i+1)
	for j := i + 1; j < len(a); j++ {
		a[i], a[j] = a[j], a[i]
		perm(a, f, i+1)
		a[i], a[j] = a[j], a[i]
	}
}

func shuffle(src string) string {
	rand.Seed(*nRandomSeedFlag)
	perm := rand.Perm(len(src))
	final := ""
	for _, v := range perm {
		final = final + string(src[v])
	}
	return final
}
