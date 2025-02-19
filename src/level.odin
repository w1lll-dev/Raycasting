package main

import rl "vendor:raylib"

SCALER: i32 : 15

InitLevel :: proc() -> rl.Image {
	return rl.LoadImage("resources/level.png")
}

InitLevelTexture :: proc(lvl: ^rl.Image) -> rl.Texture2D {
	return rl.LoadTextureFromImage(lvl^)
}

DrawLevel :: proc(lvlTex: ^rl.Texture2D) {
	rl.DrawTextureEx(lvlTex^, {0, 0}, 0, f32(SCALER), rl.WHITE)
}

