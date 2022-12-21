package main

import (
	"fmt"
	"sort"
	"strconv"
	"strings"
)

func RunDay11Part1(input string) int {
	monkeys := ParseMonkeys(input)
	inspected := make([]int, len(monkeys))
	for i := 0; i < 20; i++ {
		for _, m := range monkeys {
			for _, n := range m.Items {
				worry := m.Inspect(n)
				inspected[m.ID]++
				worry /= 3
				to := m.Test(worry)
				monkeys[to].Items = append(monkeys[to].Items, worry)
			}
			m.Items = []int{}
		}
		// PrintMonkeys(i, monkeys)
	}
	sort.Slice(inspected, func(i, j int) bool {
		return inspected[i] > inspected[j]
	})
	return inspected[0] * inspected[1]
}

func RunDay11Part2(input string) int {
	monkeys := ParseMonkeys(input)

	lcm := 1
	for _, m := range monkeys {
		lcm *= m.Divisor
	}

	inspected := make([]int, len(monkeys))
	for i := 0; i < 10000; i++ {
		for _, m := range monkeys {
			for _, n := range m.Items {
				worry := m.Inspect(n) % lcm
				inspected[m.ID]++
				to := m.Test(worry)
				monkeys[to].Items = append(monkeys[to].Items, worry)
			}
			m.Items = []int{}
		}
		// PrintMonkeys2(i, monkeys, inspected)
	}
	sort.Slice(inspected, func(i, j int) bool {
		return inspected[i] > inspected[j]
	})
	return inspected[0] * inspected[1]
}

func PrintMonkeys(round int, monkeys []*Monkey) {
	fmt.Printf("After round %d, the monkeys are holding items with these worry levels:\n", round+1)
	for _, m := range monkeys {
		fmt.Printf("Monkey %d: %v\n", m.ID, m.Items)
	}
	fmt.Print("\n")
}

func PrintMonkeys2(round int, monkeys []*Monkey, inspected []int) {
	fmt.Printf("== After round %d ==\n", round+1)
	for _, m := range monkeys {
		fmt.Printf("Monkey %d inspected items %d times.\n", m.ID, inspected[m.ID])
	}
	fmt.Print("\n")
}

type Monkey struct {
	ID          int
	Items       []int
	Operation   string
	Divisor     int
	TrueBranch  int
	FalseBranch int
}

func (m *Monkey) Inspect(old int) int {
	tokens := strings.Split(m.Operation, " ")
	op := tokens[0]
	val := tokens[1]

	var n int
	if val == "old" {
		n = old
	} else {
		m, err := strconv.Atoi(val)
		if err != nil {
			panic(err)
		}
		n = m
	}

	if op == "+" {
		return old + n
	} else if op == "*" {
		return old * n
	}
	panic("unsupported op: " + op)
}

func (m *Monkey) Test(n int) int {
	if n%m.Divisor == 0 {
		return m.TrueBranch
	}
	return m.FalseBranch
}

// Partially generated by ChatGPT
func ParseMonkeys(input string) []*Monkey {
	monkeys := []*Monkey{}
	lines := strings.Split(input, "\n")
	var currentMonkey *Monkey
	for _, line := range lines {
		if strings.HasPrefix(line, "Monkey") {
			var id int
			fmt.Sscanf(line, "Monkey %d:", &id)
			currentMonkey = &Monkey{ID: id}
			monkeys = append(monkeys, currentMonkey)
		} else if strings.HasPrefix(line, "  Starting items:") {
			itemsString := strings.TrimSpace(strings.TrimPrefix(line, "  Starting items:"))
			items := strings.Split(itemsString, ",")
			currentMonkey.Items = make([]int, len(items))
			for i, item := range items {
				var n int
				fmt.Sscanf(item, "%d", &n)
				currentMonkey.Items[i] = n
			}
		} else if strings.HasPrefix(line, "  Operation:") {
			currentMonkey.Operation = strings.TrimSpace(strings.TrimPrefix(line, "  Operation: new = old "))
		} else if strings.HasPrefix(line, "  Test:") {
			var n int
			fmt.Sscanf(line, "  Test: divisible by %d", &n)
			currentMonkey.Divisor = n
		} else if strings.HasPrefix(line, "    If true:") {
			var id int
			fmt.Sscanf(line, "    If true: throw to monkey %d", &id)
			currentMonkey.TrueBranch = id
		} else if strings.HasPrefix(line, "    If false:") {
			var id int
			fmt.Sscanf(line, "    If false: throw to monkey %d", &id)
			currentMonkey.FalseBranch = id
		} else if line == "" {
			// noop
		} else {
			panic("parse error: " + line)
		}
	}
	return monkeys
}

const Day11Input = `Monkey 0:
  Starting items: 62, 92, 50, 63, 62, 93, 73, 50
  Operation: new = old * 7
  Test: divisible by 2
    If true: throw to monkey 7
    If false: throw to monkey 1

Monkey 1:
  Starting items: 51, 97, 74, 84, 99
  Operation: new = old + 3
  Test: divisible by 7
    If true: throw to monkey 2
    If false: throw to monkey 4

Monkey 2:
  Starting items: 98, 86, 62, 76, 51, 81, 95
  Operation: new = old + 4
  Test: divisible by 13
    If true: throw to monkey 5
    If false: throw to monkey 4

Monkey 3:
  Starting items: 53, 95, 50, 85, 83, 72
  Operation: new = old + 5
  Test: divisible by 19
    If true: throw to monkey 6
    If false: throw to monkey 0

Monkey 4:
  Starting items: 59, 60, 63, 71
  Operation: new = old * 5
  Test: divisible by 11
    If true: throw to monkey 5
    If false: throw to monkey 3

Monkey 5:
  Starting items: 92, 65
  Operation: new = old * old
  Test: divisible by 5
    If true: throw to monkey 6
    If false: throw to monkey 3

Monkey 6:
  Starting items: 78
  Operation: new = old + 8
  Test: divisible by 3
    If true: throw to monkey 0
    If false: throw to monkey 7

Monkey 7:
  Starting items: 84, 93, 54
  Operation: new = old + 1
  Test: divisible by 17
    If true: throw to monkey 2
    If false: throw to monkey 1`