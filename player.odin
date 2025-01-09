package main

import rl "vendor:raylib"

Player :: struct {
	pos:    rl.Vector2,
	radius: f32,
	color:  rl.Color,
	speed:  f32,
}

DrawPlayer :: proc(plr: ^Player) {
	rl.DrawCircle(i32(plr.pos.x), i32(plr.pos.y), plr.radius, plr.color)
}

UpdatePlayer :: proc(plr: ^Player) {
	dir: rl.Vector2

	if rl.IsKeyDown(.A) {
		dir.x = -1
	} else if rl.IsKeyDown(.D) {
		dir.x = 1
	}

	if rl.IsKeyDown(.W) {
		dir.y = -1
	} else if rl.IsKeyDown(.S) {
		dir.y = 1
	}

	plr.pos += rl.Vector2Normalize(dir) * plr.speed
}
