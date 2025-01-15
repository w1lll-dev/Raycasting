package main

import rl "vendor:raylib"

Player :: struct {
	pos:          rl.Vector2,
	rayDir:       rl.Vector2,
	radius:       f32,
	moveSpeed:    f32,
	rotateAmount: f32,
	color:        rl.Color,
}

InitPlayer :: proc() -> Player {
	return {
		pos = {f32(rl.GetScreenWidth()) / 2, f32(rl.GetScreenHeight() / 2)},
		rayDir = rl.Vector2{0, -1},
		radius = 5,
		moveSpeed = 2,
		rotateAmount = 0.1,
		color = rl.GREEN,
	}
}

DrawPlayer :: proc(plr: ^Player) {
	rl.DrawCircleV(plr.pos, plr.radius, plr.color)
}

UpdatePlayer :: proc(plr: ^Player) {
	move, angle: f32

	angle = f32(i32(rl.IsKeyDown(.D)) - i32(rl.IsKeyDown(.A))) * plr.rotateAmount
	move = f32(i32(rl.IsKeyDown(.W)) - i32(rl.IsKeyDown(.S))) * plr.moveSpeed

	plr.rayDir = rl.Vector2Rotate(plr.rayDir, angle)
	plr.pos += plr.rayDir * move
}
