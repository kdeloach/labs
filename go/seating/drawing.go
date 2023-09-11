package main

import (
	"image/color"
	"math"

	"github.com/faiface/pixel"
	"github.com/faiface/pixel/imdraw"
	"github.com/faiface/pixel/pixelgl"
)

var (
	winWidth  = 1024
	winHeight = 768
)

type Object struct {
	Pos   pixel.Vec
	Shape Shape
}

type Shape int

const (
	Table Shape = iota
	Chair
)

func distance(a, b pixel.Vec) float64 {
	return math.Hypot(a.X-b.X, a.Y-b.Y)
}

func run() {
	cfg := pixelgl.WindowConfig{
		Title:  "Seating Chart Planning",
		Bounds: pixel.R(0, 0, float64(winWidth), float64(winHeight)),
		VSync:  true,
	}
	win, err := pixelgl.NewWindow(cfg)
	if err != nil {
		panic(err)
	}

	imd := imdraw.New(nil)

	var objects []Object
	var tables []pixel.Vec

	for !win.Closed() {
		win.Clear(color.White)

		if win.JustPressed(pixelgl.MouseButtonLeft) {
			pos := win.MousePosition()
			shape := Table
			if win.Pressed(pixelgl.KeyLeftShift) || win.Pressed(pixelgl.KeyRightShift) {
				shape = Chair
			}
			if shape == Table {
				tables = append(tables, pos)
			}
			objects = append(objects, Object{Pos: pos, Shape: shape})
		}

		imd.Clear()
		for _, obj := range objects {
			if obj.Shape == Table {
				imd.Color = color.RGBA{255, 0, 0, 255}
				imd.Push(obj.Pos)
				imd.Circle(20, 0)
			} else {
				imd.Color = color.RGBA{0, 0, 255, 255}
				imd.Push(obj.Pos)
				imd.Circle(5, 0)

				closestTablePos := pixel.ZV
				minDist := math.MaxFloat64
				for _, tablePos := range tables {
					dist := distance(obj.Pos, tablePos)
					if dist < minDist {
						minDist = dist
						closestTablePos = tablePos
					}
				}

				if closestTablePos != pixel.ZV {
					imd.Push(closestTablePos, obj.Pos)
					imd.Line(2)
				}
			}
		}
		imd.Draw(win)

		win.Update()
	}
}

func main() {
	pixelgl.Run(run)
}
