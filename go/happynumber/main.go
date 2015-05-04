package main

import (
    "fmt"
    "sync"
)

func main() {
    ch := make(chan int)
    go HappyNumbers(ch)
    for n := range ch {
        fmt.Print(n, " ")
    }
    fmt.Print("\n")
}

func HappyNumbers(ch chan int) {
    i := 0
    var wg sync.WaitGroup
    for i < 100 {
        wg.Add(1)
        go func(x int) {
            defer wg.Done()
            if IsHappy(x) {
                ch <- x
            }
        }(i)
        i += 1
    }
    wg.Wait()
    close(ch)
}

func IsHappy(n int) bool {
    for n > 1 && n != 4 {
        sum_digits := 0
        for _, i := range digits(n) {
            sum_digits += i * i
        }
        n = sum_digits
    }
    return n == 1
}

func digits(n int) []int {
    result := make([]int, 0)
    for n > 0 {
        result = append(result, n % 10)
        n /= 10
    }
    return result
}
