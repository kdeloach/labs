package main

import (
	"flag"
	"fmt"
	"math/rand"

	"github.com/btcsuite/btcutil/base58"
)

var nRandomSeedFlag = flag.Int64("s", 0, "random seed")
var nLettersFlag = flag.Int("n", 1, "number of letters to replace")

const Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

func main() {
	flag.Parse()

	wif := []byte("5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ")
	fmt.Printf("%s\n", wif)

	letters := []byte{}
	indexes := []int{}

	for i, c := range wif {
		if len(letters) < *nLettersFlag && !contains(letters, c) {
			letters = append(letters, c)
			indexes = append(indexes, i)
		}
	}

	fmt.Printf("%s (replacement letters)\n", letters)

	rand.Seed(*nRandomSeedFlag)
	rand.Shuffle(len(letters), func(i, j int) {
		wif[indexes[i]], wif[indexes[j]] = wif[indexes[j]], wif[indexes[i]]
		indexes[i], indexes[j] = indexes[j], indexes[i]
	})
	fmt.Printf("%s (scrambled)\n", wif)

	search(indexes, wif, 0)
}

func search(idx []int, a []byte, i int) {
	if i > len(idx) {
		// fmt.Printf("%s\n", a)
		// _, err := btcutil.DecodeWIF(string(wif))
		_, _, err := base58.CheckDecode(string(a))
		if err != nil {
			return
		}
		fmt.Printf("match: %s\n", a)
		return
	}
	search(idx, a, i+1)
	for j := i + 1; j < len(idx); j++ {
		m, n := idx[i], idx[j]
		a[m], a[n] = a[n], a[m]
		search(idx, a, i+1)
		a[m], a[n] = a[n], a[m]
	}
}

func contains(s []byte, e byte) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}
