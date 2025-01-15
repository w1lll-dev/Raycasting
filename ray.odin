package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

CalculateRayVectors :: proc(plr: ^Player) -> (rl.Vector2, rl.Vector2) {
	rayStart: rl.Vector2 = plr.pos

	rayUnitStepSize: rl.Vector2 = {
		math.sqrt(1 + (plr.rayDir.y / plr.rayDir.x) * (plr.rayDir.y / plr.rayDir.x)),
		math.sqrt(1 + (plr.rayDir.x / plr.rayDir.y) * (plr.rayDir.x / plr.rayDir.y)),
	}

	tileCheck: rl.Vector2 = rayStart
	rayLength1D: rl.Vector2

	step: rl.Vector2

	if plr.rayDir.x < 0 {
		step.x = f32(-cellSize)
		rayLength1D.x = (rayStart.x - tileCheck.x) * rayUnitStepSize.x
	} else {
		step.x = f32(cellSize)
		rayLength1D.x = (tileCheck.x + 1 - rayStart.x) * rayUnitStepSize.x
	}

	if plr.rayDir.y < 0 {
		step.y = f32(-cellSize)
		rayLength1D.y = (rayStart.y - tileCheck.y) * rayUnitStepSize.y
	} else {
		step.y = f32(cellSize)
		rayLength1D.y = (tileCheck.y + 1 - rayStart.y) * rayUnitStepSize.y
	}

	tileFound := false
	maxDist: f32 = 1000
	dist: f32 = 0
	for !tileFound && dist < maxDist {
		// Walk along shortest path
		if rayLength1D.x < rayLength1D.y {
			tileCheck.x += step.x
			dist = rayLength1D.x
			rayLength1D.x += rayUnitStepSize.x
		} else {
			tileCheck.y += step.y
			dist = rayLength1D.y
			rayLength1D.y += rayUnitStepSize.y
		}

		isCheckInLvlWidth :=
			i32(tileCheck.x) >= lvlStartX && i32(tileCheck.x) < lvlStartX + lvlWidth
		isCheckInLvlHeight :=
			i32(tileCheck.y) >= lvlStartY && i32(tileCheck.y) < lvlStartY + lvlHeight

		tileCheckGridSpace: rl.Vector2 = {
			(tileCheck.x - f32(lvlStartX)) / f32(cellSize),
			(tileCheck.y - f32(lvlStartY)) / f32(cellSize),
		}

		fmt.println(rayLength1D)

		isWall := lvl[i32(tileCheckGridSpace.y)][i32(tileCheckGridSpace.x)] == 1

		// Test tile at new test point
		if isCheckInLvlWidth && isCheckInLvlHeight && isWall {
			fmt.println("Tile Found!")
			tileFound = true
		}
	}

	// Calculate intersection location
	rayEnd: rl.Vector2
	if tileFound {
		rayEnd = rayStart + plr.rayDir * dist
	}

	fmt.println(dist)

	return rayStart, rayEnd
}

DrawRay :: proc(rayStart, rayEnd: rl.Vector2, rayColor: rl.Color) {
	rl.DrawLineV(rayStart, rayEnd, rayColor)
}
