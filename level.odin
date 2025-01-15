package main

import rl "vendor:raylib"

plane :: rl.Vector2{0, 0.66} // The 2D raycaster version of camera plane

cols, rows, cellSize: i32 : 13, 13, 50

@(rodata)
lvl: [rows][cols]i32 = {
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
	{1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1},
	{1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1},
	{1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

tilePositions: [cols][rows]rl.Vector2

lvlWidth, lvlHeight: i32 : cols * cellSize, rows * cellSize
lvlStartX, lvlStartY: i32

DrawLevel :: proc() {
	lvlStartX = (rl.GetScreenWidth() - lvlWidth) / 2
	lvlStartY = (rl.GetScreenHeight() - lvlHeight) / 2

	for x in 0 ..< cols {
		for y in 0 ..< rows {
			posX: i32 = lvlStartX + x * cellSize
			posY: i32 = lvlStartY + y * cellSize

			tilePositions[y][x] = {f32(posX), f32(posY)}

			rl.DrawRectangleLines(posX, posY, cellSize, cellSize, rl.RAYWHITE)

			if lvl[y][x] == 1 {
				rl.DrawRectangle(posX, posY, cellSize, cellSize, rl.BLUE)
			}
		}
	}
}
