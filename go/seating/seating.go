package main

import (
	"fmt"
	"math/rand"
)

type Seating []*Chair

type IterFunc func(left, middle, right *Chair)

func (s Seating) Iter(fn IterFunc) {
	chairs := []*Chair(s)
	for i := 0; i < len(chairs); i++ {
		var left, right *Chair
		middle := chairs[i]
		if i > 0 {
			left = chairs[i-1]
		}
		if i < len(chairs)-1 {
			right = chairs[i+1]
		}
		fn(left, middle, right)
	}
}

func (s Seating) Score() int {
	n := 0
	s.Iter(func(left, middle, right *Chair) {
		if middle.Person != nil {
			n += middle.Person.Happiness(left, right)
		}
	})
	return n
}

func (s Seating) String() string {
	str := "["
	chairs := []*Chair(s)
	for _, c := range chairs {
		str += fmt.Sprintf(" %s ", c.Person.Name)
	}

	str += fmt.Sprintf("] (score: %d)", s.Score())
	return str
}

type Chair struct {
	Person *Person
}

func (c *Chair) String() string {
	return c.Person.Name
}

type Person struct {
	Name       string
	Preference map[string]int
}

func NewPerson(name string) *Person {
	return &Person{name, map[string]int{}}
}

func (p *Person) Happiness(left, right *Chair) int {
	n := 0
	if left != nil && left.Person != nil {
		q := left.Person
		if p.Loves(q) {
			n += 1
		} else if p.Hates(q) {
			n += -1
		}
	}
	if right != nil && right.Person != nil {
		q := right.Person
		if p.Loves(q) {
			n += 1
		} else if p.Hates(q) {
			n += -1
		}
	}
	return n
}

func (p *Person) Love(q *Person) {
	fmt.Printf("%s loves %s\n", p.Name, q.Name)
	p.Preference[q.Name] = 1
}

func (p *Person) Loves(q *Person) bool {
	return p.Preference[q.Name] == 1
}

func (p *Person) Hate(q *Person) {
	fmt.Printf("%s hates %s\n", p.Name, q.Name)
	p.Preference[q.Name] = -1
}

func (p *Person) Hates(q *Person) bool {
	return p.Preference[q.Name] == -1
}

func createPeople() []*Person {
	a := NewPerson("Aria")
	b := NewPerson("Blake")
	c := NewPerson("Cole")
	d := NewPerson("Dean")

	fmt.Println("Rules:")
	a.Love(d)
	b.Love(a)
	c.Love(d)
	c.Hate(b)
	d.Love(a)
	d.Hate(b)

	people := []*Person{}
	people = append(people, a)
	people = append(people, b)
	people = append(people, c)
	people = append(people, d)

	rand.Shuffle(len(people), func(i, j int) {
		people[i], people[j] = people[j], people[i]
	})

	return people
}

func main() {
	people := createPeople()
	chairs := []*Chair{}
	unsortedChairs := []*Chair{}

	fmt.Println("\nBegin sorting:")
	for len(people) > 0 {
		// Unshift
		p, rest := people[0], people[1:]
		people = rest

		c := &Chair{Person: p}
		chairs = append(chairs, c)
		unsortedChairs = append(unsortedChairs, c)

		fmt.Printf("added %s: %s\n", p.Name, Seating(chairs))

		// Doesn't matter where the first 2 people sit
		if len(chairs) <= 2 {
			continue
		}

		// Record current score and position
		best := Seating(chairs).Score()
		bestIndex := len(chairs) - 1

		// There will be at least 3 chairs, and the newly added chair is at
		// index len(chairs)-1. Start from the chair right before it.
		for i := len(chairs) - 2; i >= 0; i-- {
			// Swap
			chairs[i], chairs[i+1] = chairs[i+1], chairs[i]
			fmt.Printf("swap %v and %v: %s\n", chairs[i], chairs[i+1], Seating(chairs))
			// Compare
			score := Seating(chairs).Score()
			if score > best {
				bestIndex = i
				best = score
			}
		}

		// New chair will always be at index 0 in final position
		if bestIndex > 0 {
			head := chairs[1 : bestIndex+1]
			tail := chairs[bestIndex+1:]
			tmp := make([]*Chair, len(chairs))
			copy(tmp, head)
			copy(tmp[bestIndex+1:], tail)
			tmp[bestIndex] = c
			chairs = tmp
			fmt.Printf("moving %s to %d: %s\n", p.Name, bestIndex, Seating(chairs))
		} else {
			fmt.Printf("%s already at best position\n", p.Name)
		}
	}

	fmt.Println("\nSorted:")
	Seating(chairs).Iter(func(left, middle, right *Chair) {
		score := middle.Person.Happiness(left, right)
		fmt.Printf("%s (%s)\n", middle.Person.Name, label(score))
	})

	fmt.Println("\nUnsorted:")
	Seating(unsortedChairs).Iter(func(left, middle, right *Chair) {
		score := middle.Person.Happiness(left, right)
		fmt.Printf("%s (%s)\n", middle.Person.Name, label(score))
	})
}

func label(score int) string {
	if score > 0 {
		return "happy"
	} else if score < 0 {
		return "sad"
	} else {
		return "neutral"
	}
	return ""
}
