package main

import (
	"fmt"
	"log"
	"math"
	"math/rand"
	"time"

	"github.com/faiface/pixel"
	"github.com/faiface/pixel/imdraw"
	"github.com/faiface/pixel/pixelgl"
	"github.com/faiface/pixel/text"
	"golang.org/x/image/colornames"
	"golang.org/x/image/font/basicfont"
)

var people []Person
var origin pixel.Vec

const (
	windowWidth  = 1024
	windowHeight = 768
	circleRadius = 250
	personRadius = 30
	numPeople    = 10 + 1 // +1 for origin (invisible)
)

var colorBlack = parseHex("000000") // origin

var palette = []pixel.RGBA{
	parseHex("FF0000"),
	parseHex("FF8700"),
	parseHex("FFD300"),
	parseHex("DEFF0A"),
	parseHex("A1FF0A"),
	parseHex("0AFF99"),
	parseHex("0AEFFF"),
	parseHex("147DF5"),
	parseHex("580AFF"),
	parseHex("BE0AFF"),
}

type Person struct {
	Pos   pixel.Vec
	Vel   pixel.Vec
	Color pixel.RGBA
	Love  map[*Person]float64
	Name  string
}

func main() {
	pixelgl.Run(run)
}

func run() {
	cfg := pixelgl.WindowConfig{
		Title:  "Drawing",
		Bounds: pixel.R(0, 0, windowWidth, windowHeight),
		VSync:  true,
	}

	win, err := pixelgl.NewWindow(cfg)
	if err != nil {
		panic(err)
	}

	rand.Seed(time.Now().UnixNano())

	origin = pixel.V(float64(windowWidth)/2, float64(windowHeight)/2)

	reset()

	paused := false

	basicAtlas := text.NewAtlas(basicfont.Face7x13, text.ASCII)

	for !win.Closed() {
		win.Clear(colornames.White)

		imd := imdraw.New(nil)

		origin = win.MousePosition()
		people[0].Pos = origin

		// // Draw blue circle outline
		// imd.Color = pixel.RGB(0, 0, 1) // Blue color
		// imd.Push(origin)
		// imd.Circle(circleRadius, 2)
		// imd.Draw(win)

		// Draw people
		for i, person := range people {
			// Skip origin
			if i == 0 {
				continue
			}

			// Circle
			imd.Color = person.Color
			imd.Push(person.Pos)
			imd.Circle(personRadius, 0) // Use line width of 0 for filled circle

			// Line
			// imd.Color = pixel.RGBA{0, 0, 0, 1}
			// imd.Push(person.Pos)
			// imd.Push(person.Pos.Add(person.Vel.Scaled(5)))
			// imd.Line(2)
		}

		imd.Draw(win)

		for _, person := range people {
			basicTxt := text.New(person.Pos, basicAtlas)
			basicTxt.Color = colornames.Black
			basicTxt.Dot.X -= basicTxt.BoundsOf(person.Name).W() / 2
			basicTxt.Dot.Y -= 4
			fmt.Fprintln(basicTxt, person.Name)
			basicTxt.Draw(win, pixel.IM)
		}

		win.Update()

		if win.JustPressed(pixelgl.KeySpace) {
			paused = !paused
		}

		if !paused {
			updatePeople(people)
			// time.Sleep(time.Millisecond) // Sleep to slow down updates
		}

		if win.Pressed(pixelgl.KeyR) {
			reset()
		}
		if win.Pressed(pixelgl.MouseButton1) {
			blast()
		}
	}
}

func reset() {
	// Initialize people
	people = make([]Person, numPeople)

	people[0] = Person{
		Pos:   origin,
		Color: colorBlack,
		Love:  make(map[*Person]float64),
	}

	for i := 1; i < numPeople; i++ {
		// Don't include origin in numPeople
		theta := 2 * math.Pi * float64(i) / float64(numPeople-1)
		pos := pixel.Unit(theta).Scaled(circleRadius).Add(origin)
		people[i] = Person{
			Pos:   pos,
			Color: palette[i%len(palette)],
			Love:  make(map[*Person]float64),
		}

		// Assign attraction levels
		// for j := 1; j < numPeople; j++ {
		// 	if i != j {
		// 		// // Randomly assign attraction levels between -1 and 1
		// 		// people[i].Love[&people[j]] = rand.Float64()*2 - 1

		// 		// By color
		// 		p2 := &people[j]
		// 		people[i].Love[p2] = ColorDistance(people[i].Color, p2.Color)
		// 	}
		// }
	}

	love := +1.0
	frnd := +0.5 // friend
	peer := +0.2
	self := +0.0
	strg := -0.2 // stranger
	avod := -0.5 // avoid
	hate := -1.0

	names := []string{"Clark", "Lex", "Lana", "Lois", "Chloe", "Pete", "Jimmy", "Oliver", "Martha", "Jonathan"}

	characters := [][]float64{
		{self, hate, love, love, frnd, frnd, peer, frnd, love, love}, // 0. Clark
		{hate, self, love, strg, peer, avod, avod, peer, peer, peer}, // 1. Lex
		{love, hate, self, frnd, love, frnd, strg, strg, peer, peer}, // 2. Lana
		{love, hate, frnd, self, love, strg, peer, love, peer, peer}, // 3. Lois
		{love, hate, love, love, self, frnd, love, love, peer, peer}, // 4. Chloe
		{frnd, hate, frnd, strg, love, self, strg, strg, peer, peer}, // 5. Pete
		{peer, avod, strg, peer, love, strg, self, strg, strg, strg}, // 6. Jimmy
		{frnd, hate, strg, love, love, strg, strg, self, strg, strg}, // 7. Oliver
		{love, hate, peer, peer, peer, peer, strg, strg, self, love}, // 8. Martha
		{love, hate, peer, peer, peer, peer, strg, strg, love, self}, // 9. Jonathan
	}

	for i, others := range characters {
		for j, v := range others {
			if i == j {
				continue
			}
			// +1 to skip origin
			people[i+1].Love[&people[j+1]] = v
			people[i+1].Name = names[i]
		}
	}
}

func blast() {
	for i := 1; i < numPeople; i++ {
		burst := pixel.Unit(people[i].Pos.Sub(origin).Angle()).Scaled(5)
		people[i].Vel = people[i].Vel.Add(burst)
	}
}

func updatePeople(people []Person) {
	// Friction
	for i := range people {
		// p1 := people[i]
		// delta := origin.Sub(p1.Pos)
		// distance := delta.Len()
		// angle := delta.Angle()
		// speed := distance / 100
		// vel := pixel.Unit(angle).Scaled(speed)
		// people[i].Vel = people[i].Vel.Add(vel)

		// Friction
		people[i].Vel = people[i].Vel.Scaled(0.98)
	}

	// Implement your attraction/repulsion logic here
	for i := range people {
		// Origin doesn't move
		if i == 0 {
			continue
		}
		for j := range people {
			if i != j {
				p1 := people[i]
				p2 := people[j]

				delta := p2.Pos.Sub(p1.Pos)
				distance := delta.Len()
				angle := delta.Angle()

				if distance <= personRadius*2 {
					continue
				}

				// Adjust the velocity based on attraction/repulsion rules
				// Example: People who love each other move closer (0.5), those who hate move farther (1.5)
				attraction, _ := people[i].Love[&people[j]]

				scale := 1 / distance
				speed := attraction * scale * 10

				if j == 0 {
					speed = distance / 5000
				}

				vel := pixel.Unit(angle).Scaled(speed)
				people[i].Vel = people[i].Vel.Add(vel)
			}
		}

		// Clamp
		// v := people[i].Vel
		// v = v.Scaled(4 / v.Len())
		// people[i].Vel = v
		// fmt.Println(people[i].Vel.Len())
	}

	// Apply the velocity to update positions
	for i := range people {
		people[i].Pos = people[i].Pos.Add(people[i].Vel)

		// Stay inside the circle
		// if origin.Sub(people[i].Pos).Len() > circleRadius+personRadius*2 {
		// 	people[i].Pos = origin
		// }

		// Limit the maximum speed to prevent people from teleporting too far
		// maxSpeed := 5.0
		// speed := math.Sqrt(people[i].Vel.X*people[i].Vel.X
		// + people[i].Vel.Y*people[i].Vel.Y)
		// if speed > maxSpeed {
		// 	scale := maxSpeed / speed
		// 	people[i].Vel.X *= scale
		// 	people[i].Vel.Y *= scale
		// }
	}

	// Collision detection and avoidance
	collision := true
	rounds := 100

	for collision && rounds > 0 {
		collision = false
		for i := range people {
			// Skip origin
			if i == 0 {
				continue
			}
			for j := range people {
				// Can't collide with origin
				if j == 0 {
					continue
				}
				if i != j {
					p1 := &people[i]
					p2 := &people[j]
					delta := p2.Pos.Sub(p1.Pos)
					distance := delta.Len()
					if distance < personRadius*2 { // Adjust the collision threshold as needed
						collision = true
						rounds -= 1

						// Calculate collision angle
						angle := delta.Angle()
						overlap := pixel.Unit(angle).Scaled(personRadius*2 - distance)
						// Move both people away from each other
						p1.Pos = p1.Pos.Sub(overlap)
						p2.Pos = p2.Pos.Add(overlap)
					}
				}
			}
		}
	}
}

func parseHex(s string) pixel.RGBA {
	var r, g, b int64
	_, err := fmt.Sscanf(s, "%02X%02X%02X", &r, &g, &b)
	if err != nil {
		log.Print(err)
	}
	return pixel.RGBA{
		R: float64(r) / 255,
		G: float64(g) / 255,
		B: float64(b) / 255,
		A: 0xff,
	}
}

// ColorDistance calculates the color difference between two pixel.RGBA colors
// and returns a normalized value in the range from -1 to 1.
func ColorDistance(color1, color2 pixel.RGBA) float64 {
	rDiff := float64(color1.R - color2.R)
	gDiff := float64(color1.G - color2.G)
	bDiff := float64(color1.B - color2.B)

	// Calculate the Euclidean color distance
	distance := math.Sqrt(rDiff*rDiff + gDiff*gDiff + bDiff*bDiff)

	// Normalize the distance to the range [-1, 1]
	maxDistance := math.Sqrt(3) // Maximum Euclidean distance for RGB colors
	normalizedDistance := 2*(distance/maxDistance) - 1

	return normalizedDistance
}
