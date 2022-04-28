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
	wifOrigLen := len(wifOrig)
	fmt.Printf("%v\n", wifOrig)

	wifPart := []byte{}
	letters := ""
	indexes := []int{}

	for i := 0; i < len(wifOrig); i++ {
		c := wifOrig[i]
		if len(letters) < *nLettersFlag && !strings.Contains(letters, string(c)) {
			wifPart = append(wifPart, byte('0'))
			letters = letters + string(c)
			indexes = append(indexes, i)
		} else {
			wifPart = append(wifPart, c)
		}
	}

	fmt.Printf("%s\n", wifPart)
	fmt.Printf("%v (replaced %d letters)\n", letters, len(letters))

	letters = shuffle(letters)
	fmt.Printf("%v (scrambled)\n", letters)

	perm([]byte(letters), func(rcs []byte) {
		wif2 := make([]byte, wifOrigLen)
		copy(wif2, wifPart)
		for i, idx := range indexes {
			wif2[idx] = rcs[i]
		}

		_, err := btcutil.DecodeWIF(string(wif2))
		if err != nil {
			return
		}

		fmt.Printf("match found: %s\n", wif2)
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
