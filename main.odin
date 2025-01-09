package main

import rl "vendor:raylib"

WIN_WIDTH :: 1600
WIN_HEIGHT :: 900

main :: proc() {
	rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Raycasting")

	rl.SetTargetFPS(60)

	plr := Player{{WIN_WIDTH / 2, WIN_HEIGHT / 2}, 10, rl.GREEN, 5}

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.BLACK)

		UpdatePlayer(&plr)
		DrawPlayer(&plr)
	}
}
