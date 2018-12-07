package main

import (
	"fmt"
	"io"
	"os"
)

type point struct {
	x, y int
}

/// Hey Go… why don't you have min/max functions?
func min(x int, y int) int {
	if x < y {
		return x
	}
	return y
}

func max(x int, y int) int {
	if x < y {
		return y
	}
	return x
}

func abs(x int) int {
	return max(x, -x)
}

func (p point) distance(other point) int {
	dx := p.x - other.x
	dy := p.y - other.y
	return abs(dx) + abs(dy)
}

func (p point) distanceAll(points []point) int {
	total := 0
	for _, other := range points {
		total += p.distance(other)
	}
	return total
}

func (p point) neighbors() [4]point {
	return [4]point{
		point{x: p.x - 1, y: p.y},
		point{x: p.x + 1, y: p.y},
		point{x: p.x, y: p.y - 1},
		point{x: p.x, y: p.y + 1},
	}
}

func readPoints() []point {
	// Read in the points
	var p point
	points := make([]point, 0)
	for {
		n, err := fmt.Fscanf(os.Stdin, "%d, %d\n", &p.x, &p.y)
		if err == io.EOF {
			break
		} else if err != nil {
			panic(err)
		} else if n != 2 {
			panic("Invalid format")
		}
		points = append(points, p)
	}
	return points
}

func findBBox(points []point) (int, int, int, int) {
	left := points[0].x
	right := left
	top := points[0].y
	bottom := top
	for _, point := range points {
		left = min(left, point.x)
		right = max(right, point.x)
		top = min(top, point.y)
		bottom = max(bottom, point.y)
	}
	return left, right, top, bottom
}

func main() {
	points := readPoints()
	if len(points) == 0 {
		panic("Read 0 points")
	}

	left, right, top, bottom := findBBox(points)
	width := right - left + 1
	height := bottom - top + 1

	// Compute the distance field
	closest := make([][]int, height)
	areas := make(map[int]int)
	for i := 0; i < height; i++ {
		y := i + top
		closest[i] = make([]int, width)
		for j := 0; j < width; j++ {
			x := j + left
			current := point{x: x, y: y}
			closestPoint, dist := 0, points[0].distance(current)
			for n, point := range points {
				newDist := point.distance(current)
				if newDist < dist {
					dist = newDist
					closestPoint = n
				} else if newDist == dist {
					closestPoint = -1
				}
			}
			closest[i][j] = closestPoint
			areas[closestPoint]++
		}
	}

	// Filter to only the points with a finite area
	finitePoints := make([]int, 0)
	for n, point := range points {
		if closest[0][point.x-left] == n || closest[height-1][point.x-left] == n {
			continue
		} else if closest[point.y-top][0] == n || closest[point.y-top][width-1] == n {
			continue
		}
		finitePoints = append(finitePoints, n)
	}

	maxArea := 0
	for _, n := range finitePoints {
		if areas[n] > maxArea {
			maxArea = areas[n]
		}
	}
	fmt.Printf("%d\n", maxArea)

	// Part 2
	CUTOFF := 10000
	safeArea := 0
	next := append([]point(nil), points...)
	visited := make(map[point]bool)
	for _, point := range points {
		visited[point] = true
	}

	for len(next) != 0 {
		point := next[len(next)-1]
		next = next[:len(next)-1]
		if point.distanceAll(points) >= CUTOFF {
			continue
		}
		safeArea++
		for _, neighbor := range point.neighbors() {
			if !visited[neighbor] {
				visited[neighbor] = true
				next = append(next, neighbor)
			}
		}
	}
	fmt.Printf("%d\n", safeArea)
}
