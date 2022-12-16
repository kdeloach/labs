package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
)

func main() {
	words := []string{}

	file, err := os.Open("words-allowed.txt")
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

	data, err := json.Marshal(words)
	if err != nil {
		panic(err)
	}

	fmt.Printf("%s\n", data)
}
