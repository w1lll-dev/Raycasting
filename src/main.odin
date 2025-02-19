package main

import rl "vendor:raylib"

WIN_WIDTH, WIN_HEIGHT: i32 : 600, 400

main :: proc() {
	// Setup
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.SetTargetFPS(60)

	rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Raycasting")
	defer rl.CloseWindow()

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	bgMusic: rl.Music = rl.LoadMusicStream("resources/music.mp3")

	rl.PlayMusicStream(bgMusic)
	defer rl.UnloadMusicStream(bgMusic)

	// Initialization
	plr := InitPlayer()
	lvl := InitLevel()
	rc := InitRaycaster()
	lvlTex := InitLevelTexture(&lvl)
	textures := InitTextures()
	texMap := InitTextureMap(&textures)

	// Game Loop
	for !rl.WindowShouldClose() {
		// Updating
		UpdatePlayer(&plr, &lvl)
		UpdateRaycaster(&rc, &plr, &lvl, &textures, &texMap)
		rl.UpdateMusicStream(bgMusic)

		// Drawing
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.BLACK)

		DrawScreenTexture(&rc.screenTex)
		DrawRaycasterPlayer(&plr)

		DrawLevel(&lvlTex)
		DrawRays(&plr.pos, &rc.rayEnds)
		DrawLevelPlayer(&plr)
	}
}

