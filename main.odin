package main

import rl "vendor:raylib"

winWidth, winHeight: i32 : 1600, 900

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(winWidth, winHeight, "Raycasting")

	rl.SetTargetFPS(60)

	plr := InitPlayer()

	for !rl.WindowShouldClose() {


		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.BLACK)

		DrawLevel()

		UpdatePlayer(&plr)
		DrawPlayer(&plr)

		rayStart, rayEnd := CalculateRayVectors(&plr)
		DrawRay(rayStart, rayEnd, rl.RED)
	}

	rl.CloseWindow()
}
