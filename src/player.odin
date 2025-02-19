package main

import rl "vendor:raylib"

timer: f32
canAnimate: bool

Player :: struct {
	pos:        Vec2,
	dir:        Vec2,
	plane:      Vec2,
	radius:     f32,
	moveSpeed:  f32,
	sens:       f32,
	color:      rl.Color,
	tex:        rl.Texture2D,
	frameRec:   rl.Rectangle,
	curFrame:   i32,
	frameSpeed: f32,
	shootSound: rl.Sound,
	hasShot:    bool,
}

InitPlayer :: proc() -> Player {
	rl.DisableCursor()

	tex: rl.Texture2D = rl.LoadTexture("resources/player.png")
	frameRec: rl.Rectangle = {0, 0, f32(tex.width / 5), f32(tex.height)}

	return {
		pos = {1.5, 1.5},
		dir = {1, 0},
		plane = {0, 0.9},
		radius = 5,
		moveSpeed = 3,
		sens = 0.5,
		color = rl.ORANGE,
		tex = tex,
		frameRec = frameRec,
		frameSpeed = 1000,
		shootSound = rl.LoadSound("resources/revolver.wav"),
	}
}

UpdatePlayer :: proc(plr: ^Player, lvl: ^rl.Image) {
	angle: f32
	move: Vec2

	angle = rl.GetMouseDelta().x * plr.sens
	move.x = f32(i32(rl.IsKeyDown(.W)) - i32(rl.IsKeyDown(.S))) * plr.moveSpeed * rl.GetFrameTime()
	move.y = f32(i32(rl.IsKeyDown(.A)) - i32(rl.IsKeyDown(.D))) * plr.moveSpeed * rl.GetFrameTime()

	nextPosX: f32 = plr.pos.x + plr.dir.x * move.x - plr.plane.x * move.y
	nextPosY: f32 = plr.pos.y + plr.dir.y * move.x - plr.plane.y * move.y
	nextPosIsWall: bool = rl.GetImageColor(lvl^, i32(nextPosX), i32(nextPosY)) != rl.BLACK

	if !nextPosIsWall do plr.pos = Vec2{nextPosX, nextPosY}

	plr.dir = rl.Vector2Rotate(plr.dir, angle * rl.GetFrameTime())
	plr.plane = rl.Vector2Rotate(plr.plane, angle * rl.GetFrameTime())

	if rl.IsMouseButtonPressed(.LEFT) && !canAnimate {
		canAnimate = true
		plr.hasShot = true
		rl.PlaySound(plr.shootSound)
	} else do plr.hasShot = false

	if canAnimate do timer += rl.GetFrameTime()

	if timer >= 60 / plr.frameSpeed {
		timer = 0
		plr.curFrame += 1

		if plr.curFrame > 4 {
			plr.curFrame = 0
			canAnimate = false
		}

		plr.frameRec.x = f32(plr.curFrame) * f32(plr.tex.width / 5)
	}
}

DrawLevelPlayer :: proc(plr: ^Player) {
	rl.DrawCircleV(plr.pos * f32(SCALER), plr.radius, plr.color)
}

DrawRaycasterPlayer :: proc(plr: ^Player) {
	rl.DrawTexturePro(
		plr.tex,
		plr.frameRec,
		{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())},
		{0, 0},
		0,
		rl.WHITE,
	)
}

