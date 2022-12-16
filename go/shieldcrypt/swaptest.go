package main

import "fmt"

func main() {
	a := []byte{'a', 'b', 'c', 'd', 'e'}

	test(a)

	fmt.Printf("%s\n", a)
}

func test(b []byte) {
	b[0], b[1] = b[1], b[0]
}
