package main

import (
	"fmt"
	"strings"
)

type OrderedPlates []float32
type OrderedPlateCollection []OrderedPlates
type OrderedPlatesByWeight map[float32]OrderedPlateCollection

type Node struct {
	Parent   *Node
	Plate    float32
	Weight   float32
	Children map[float32]*Node
	Depth    int
}

func NewNode(parent *Node, plate float32) *Node {
	depth := 0
	weight := plate
	if parent != nil {
		weight += parent.Weight
		depth = parent.Depth + 1
	}
	return &Node{
		Parent:   parent,
		Plate:    plate,
		Weight:   weight,
		Children: make(map[float32]*Node),
		Depth:    depth,
	}
}

func (node *Node) TotalWeight() int {
	return int(45 + node.Weight*2)
}

func (node *Node) Score() int {
	score := node.Depth + 1

	if node.Parent != nil {
		// Prefer ordered from heavy to light
		if node.Plate > node.Parent.Plate {
			score += int(node.Plate - node.Parent.Plate)
		}
		score += node.Parent.Score()
	}

	// n := node
	// for n != nil {
	// 	if n.Parent != nil && n.Plate > n.Parent.Plate {
	// 		score += 1
	// 	}
	// 	n = n.Parent
	// }

	return score
}

func (node *Node) String() string {
	plates := []float32{node.Plate}
	for parent := node.Parent; parent != nil; parent = parent.Parent {
		plates = append(plates, parent.Plate)
	}
	var sb strings.Builder
	for i := len(plates) - 1; i >= 0; i-- {
		sb.WriteString(fmt.Sprintf("%v", plates[i]))
		if i > 0 {
			sb.WriteString("->")
		}
	}
	return sb.String()
}

type Tree struct {
	Children map[float32]*Node
}

func NewTree() *Tree {
	return &Tree{
		Children: make(map[float32]*Node),
	}
}

func (tree *Tree) Add(plates OrderedPlates) {
	var parent *Node
	for _, p := range plates {
		node := tree.getOrCreateNode(parent, p)
		parent = node
	}
}

func (tree *Tree) getOrCreateNode(parent *Node, plate float32) *Node {
	var children map[float32]*Node
	if parent != nil {
		children = parent.Children
	} else {
		children = tree.Children
	}
	node, ok := children[plate]
	if ok {
		return node
	}
	node = NewNode(parent, plate)
	children[plate] = node
	return node
}

func (tree *Tree) Distance(a, b *Node) int {
	c := tree.Ancestor(a, b)
	if c == nil {
		return a.Depth + b.Depth + 2
	}
	return (a.Depth - c.Depth) + (b.Depth - c.Depth)
}

func (tree *Tree) Ancestor(a, b *Node) *Node {
	p1 := a
	p2 := b

	for p1 != nil && p2 != nil && p1 != p2 {
		if p1.Depth > p2.Depth {
			p1 = p1.Parent
		} else if p2.Depth > p1.Depth {
			p2 = p2.Parent
		} else {
			p1 = p1.Parent
			p2 = p2.Parent
		}
	}

	if p1 != p2 {
		return nil
	}
	return p1
}

type WalkTreeFn func(*Node)

func walkTree(tree *Tree, fn WalkTreeFn) {
	for _, node := range tree.Children {
		walkNode(node, fn)
	}
}

func walkNode(node *Node, fn WalkTreeFn) {
	fn(node)
	for _, child := range node.Children {
		walkNode(child, fn)
	}
}

func walkNearbyNodes(node *Node, distance int, fn WalkTreeFn) {
	seen := make(map[*Node]bool)

	var walk func(node *Node, distance int)

	walk = func(node *Node, distance int) {
		if node == nil || distance < 0 {
			return
		}
		if _, ok := seen[node]; ok {
			return
		}

		fn(node)
		seen[node] = true

		for _, child := range node.Children {
			walk(child, distance-1)
		}
		walk(node.Parent, distance-1)
	}

	walk(node, distance)
}

func permutations(plates OrderedPlates) OrderedPlateCollection {
	platesColl := make(OrderedPlateCollection, 0)
	if len(plates) == 0 {
		return platesColl
	}
	for i, p := range plates {
		subPlates := make(OrderedPlates, 0, len(plates)-1)
		subPlates = append(subPlates, plates[:i]...)
		subPlates = append(subPlates, plates[i+1:]...)

		platesColl = append(platesColl, []float32{p})

		for _, pz := range permutations(subPlates) {
			perm := append([]float32{p}, pz...)
			platesColl = append(platesColl, perm)
		}
	}
	return platesColl
}

func main() {
	plates := []float32{45, 35, 25, 10, 10, 5, 5, 2.5}

	// TODO: use channel
	tree := NewTree()
	for _, perm := range permutations(plates) {
		tree.Add(perm)
	}

	// a := tree.Children[45].Children[35].Children[25]
	// walkNearbyNodes(a, 400, func(a *Node) {
	// 	fmt.Printf("%v\n", a)
	// })

	best := 999
	solution := []*Node{}

	p1 := 85
	p2 := 100
	p3 := 110
	p4 := 85

	// Can add or remove up to 4 plates
	distance := 4

	walkTree(tree, func(a *Node) {
		if a.TotalWeight() == p1 {
			walkNearbyNodes(a, distance, func(b *Node) {
				if b.TotalWeight() == p2 {
					d1 := tree.Distance(a, b)
					walkNearbyNodes(b, distance, func(c *Node) {
						if c.TotalWeight() == p3 {
							d2 := tree.Distance(b, c)
							walkNearbyNodes(c, distance, func(d *Node) {
								if d.TotalWeight() == p4 {
									d3 := tree.Distance(c, d)
									score := a.Score() + (b.Score() * d1) + (c.Score() * d2) + (d.Score() * d3)
									if score < best {
										best = score
										solution = []*Node{a, b, c, d}
										fmt.Printf("%v (score=%v) --> %v (score=%v) --> %v (score=%v) --> %v (score=%v) total=%v\n", a, a.Score(), b, b.Score(), c, c.Score(), d, d.Score(), score)
									}
								}
							})
						}
					})
				}
			})
		}
	})

	fmt.Printf("solution = %v\n", solution)

	// a := tree.Children[45].Children[35].Children[25]
	// b := tree.Children[35]
	// d := tree.Distance(a, b)
	// fmt.Printf("%v --> %v distance=%v\n", a, b, d)
}
