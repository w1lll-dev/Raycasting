package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

buffer: [WIN_HEIGHT][WIN_WIDTH]rl.Color
zBuffer: [WIN_WIDTH]f32

Raycaster :: struct {
	screenTex: rl.Texture2D,
	rayEnds:   [WIN_WIDTH]Vec2,
}

InitRaycaster :: proc() -> Raycaster {
	img: rl.Image = {&buffer, WIN_WIDTH, WIN_HEIGHT, 1, .UNCOMPRESSED_R8G8B8A8}
	return {screenTex = rl.LoadTextureFromImage(img)}
}

UpdateRaycaster :: proc(
	rc: ^Raycaster,
	plr: ^Player,
	lvl: ^rl.Image,
	textures: ^[len(TEXTURE_PATHS)]rl.Image,
	texMap: ^map[rl.Color]rl.Image,
) {
	texWidth := textures[0].width
	texHeight := textures[0].height

	// FLOOR CASTING
	for y in WIN_HEIGHT / 2 + 1 ..< WIN_HEIGHT {
		// rayDir for leftmost ray (x = 0) and rightmost ray (x = w)
		rayDirLeft: Vec2 = plr.dir - plr.plane
		rayDirRight: Vec2 = plr.dir + plr.plane

		// Current y-position compared to the center of the screen (the horizon)
		p: i32 = y - WIN_HEIGHT / 2

		// Vertical position of the camera
		posZ: f32 = 0.5 * f32(WIN_HEIGHT)

		// Horizontal distance from the camera to the floor for the current row
		rowDist: f32 = posZ / f32(p)

		// Calculate the real world step vector we have to add for each x (parallel to camera plane)
		floorStep: Vec2 = rowDist * (rayDirRight - rayDirLeft) / f32(WIN_WIDTH)

		// Real world coordinates of the leftmost column. This will be updated as we step to the right
		floor: Vec2 = plr.pos + rowDist * rayDirLeft

		for x in 0 ..< WIN_WIDTH {
			// The cell coordinate is simply gotten from the i32 parts of floor
			cell: Vec2i = Vec2ToVec2i(floor)

			// Get the texture coordinate from the fractional part
			texX: i32 = i32(f32(texWidth) * (floor.x - f32(cell.x))) & (texWidth - 1)
			texY: i32 = i32(f32(texHeight) * (floor.y - f32(cell.y))) & (texHeight - 1)

			floor.x += floorStep.x
			floor.y += floorStep.y

			// Choose texture and draw the pixel
			floorTex: i32 = 4
			ceilingTex: i32 = 5
			color: rl.Color

			// Floor
			color = rl.GetImageColor(textures[floorTex], texX, texY)
			buffer[y][x] = color

			// Ceiling (symmetrical, at WIN_HEIGHT - y - 1 instead of y)
			color = rl.GetImageColor(textures[ceilingTex], texX, texY)
			buffer[WIN_HEIGHT - y - 1][x] = color
		}
	}

	// WALL CASTING
	for x in 0 ..< WIN_WIDTH {
		// x-coordinate in camera space
		cameraX: f32 = 2 * f32(x) / f32(WIN_WIDTH) - 1

		// Ray direction
		rayDir: Vec2 = plr.dir + plr.plane * cameraX

		// Which tile of the level we're in
		tileCheck: Vec2i = Vec2ToVec2i(plr.pos)

		// Ray length from current position to next x or y side
		sideDist: Vec2

		// Ray length from one x or y-side to next x or y side
		deltaDist: Vec2 = {
			rayDir.x == 0 ? 1e30 : math.abs(1 / rayDir.x),
			rayDir.y == 0 ? 1e30 : math.abs(1 / rayDir.y),
		}

		// What direction to step in x or y direction (either +1 or -1)
		step: Vec2i

		// Calculate step and initial sideDist
		if rayDir.x < 0 {
			step.x = -1
			sideDist.x = (plr.pos.x - f32(tileCheck.x)) * deltaDist.x
		} else {
			step.x = 1
			sideDist.x = (f32(tileCheck.x + 1) - plr.pos.x) * deltaDist.x
		}

		if rayDir.y < 0 {
			step.y = -1
			sideDist.y = (plr.pos.y - f32(tileCheck.y)) * deltaDist.y
		} else {
			step.y = 1
			sideDist.y = (f32(tileCheck.y + 1) - plr.pos.y) * deltaDist.y
		}

		// Perform DDA
		hitWall := false
		hitX := false
		maxDist: f32 = 100
		dist: f32 = 0
		for !hitWall && dist < maxDist {
			// Walk along shortest path
			if sideDist.x < sideDist.y {
				tileCheck.x += step.x
				dist = sideDist.x
				sideDist.x += deltaDist.x
				hitX = true
			} else {
				tileCheck.y += step.y
				dist = sideDist.y
				sideDist.y += deltaDist.y
				hitX = false
			}

			// Check if ray hit a wall
			isWall := rl.GetImageColor(lvl^, tileCheck.x, tileCheck.y) != rl.BLACK
			if isWall do hitWall = true
		}

		// Calculate intersection location
		rayEnd: Vec2
		if hitWall do rayEnd = plr.pos + rayDir * dist
		rc.rayEnds[x] = rayEnd

		// Calculate distance projected on camera direction. AKA the shortest distance from the
		// point where the wall is hit to the camera plane. This is done to avoid fisheye effect.
		perpWallDist: f32

		if hitX do perpWallDist = sideDist.x - deltaDist.x
		else do perpWallDist = sideDist.y - deltaDist.y

		// Calculate height of line to draw on screen
		lineHeight: f32 = f32(WIN_HEIGHT) / perpWallDist

		// Calculate lowest and highest pixel to fill in current stripe
		drawStart: i32 = i32(-lineHeight) / 2 + WIN_HEIGHT / 2
		if drawStart < 0 do drawStart = 0
		drawEnd: i32 = i32(lineHeight) / 2 + WIN_HEIGHT / 2
		if drawEnd >= WIN_HEIGHT do drawEnd = WIN_HEIGHT - 1

		// Texturing calculations
		texColor: rl.Color = rl.GetImageColor(lvl^, tileCheck.x, tileCheck.y)

		// Calculate value of wallX
		wallX: f32
		if hitX do wallX = plr.pos.y + perpWallDist * rayDir.y
		else do wallX = plr.pos.x + perpWallDist * rayDir.x
		wallX -= math.floor(wallX)

		// x-coordinate on the texture
		texX: i32 = i32(wallX * f32(texWidth))
		if (hitX && rayDir.x > 0) || (!hitX && rayDir.y < 0) do texX = texWidth - texX - 1

		// How much to increase the texture coordinate per screen pixel
		texStep: f32 = f32(texHeight) / lineHeight

		// Starting texture coordinate
		texPos: f32 = (f32(drawStart) - f32(WIN_HEIGHT) / 2 + lineHeight / 2) * texStep
		for y in drawStart ..< drawEnd {
			// Cast the texture coordinate to i32 and mask with (texHeight - 1) in case of overflow
			texY: i32 = i32(texPos) & (texHeight - 1)
			texPos += texStep
			color: rl.Color = rl.GetImageColor(texMap[texColor], texX, texY)

			// Make color darker for y-sides
			if !hitX do color /= 2

			buffer[y][x] = color
		}

		// Set the z buffer for sprite casting 
		zBuffer[x] = perpWallDist
	}

	// SPRITE CASTING
	// Sort sprites from far to close
	for i in 0 ..< i32(len(SPRITES)) {
		spriteOrder[i] = i
		spriteDist[i] =
			(plr.pos.x - SPRITES[i].pos.x) * (plr.pos.x - SPRITES[i].pos.x) +
			(plr.pos.y - SPRITES[i].pos.y) * (plr.pos.y - SPRITES[i].pos.y)
	}
	SortSprites(&spriteOrder, &spriteDist)

	// After sorting the sprites, do the projection and draw them
	for i in 0 ..< i32(len(SPRITES)) {
		// Translate sprite position to relative to camera
		spritePos: Vec2 = SPRITES[spriteOrder[i]].pos - plr.pos


		// Transform sprite with the inverse camera matrix
		invDet: f32 = 1.0 / (plr.plane.x * plr.dir.y - plr.dir.x * plr.plane.y)

		transform: Vec2
		transform.x = invDet * (plr.dir.y * spritePos.x - plr.dir.x * spritePos.y)
		transform.y = invDet * (-plr.plane.y * spritePos.x + plr.plane.x * spritePos.y)

		spriteScreenX: f32 = f32(WIN_WIDTH) / 2 * (1 + transform.x / transform.y)

		// Calculate height of the sprite on screen
		spriteHeight: f32 = math.abs(f32(WIN_HEIGHT) / transform.y)

		// Calculate lowest and highest pixel to fill in current stripe
		drawStartY: i32 = i32(-spriteHeight) / 2 + WIN_HEIGHT / 2
		if drawStartY < 0 do drawStartY = 0
		drawEndY: i32 = i32(spriteHeight) / 2 + WIN_HEIGHT / 2
		if drawEndY >= WIN_HEIGHT do drawEndY = WIN_HEIGHT - 1

		// Calculate width of the sprite
		spriteWidth: f32 = math.abs(f32(WIN_HEIGHT) / transform.y)

		// Calculate lowest and highest pixel to fill in current stripe
		drawStartX: i32 = i32(-spriteWidth) / 2 + i32(spriteScreenX)
		if drawStartX < 0 do drawStartX = 0
		drawEndX: i32 = i32(spriteWidth) / 2 + i32(spriteScreenX)
		if drawEndX > WIN_WIDTH do drawEndX = WIN_WIDTH

		// Loop through every vertical stripe of the sprite on screen
		for x in drawStartX ..< drawEndX {
			texX: i32 = i32(x - drawStartX) * texWidth / i32(spriteWidth)

			if transform.y > 0 && transform.y < zBuffer[x] {
				for y in drawStartY ..< drawEndY {
					d: i32 = y - WIN_HEIGHT / 2 + i32(spriteHeight) / 2
					texY: i32 = d * texHeight / i32(spriteHeight)
					color: rl.Color = rl.GetImageColor(
						textures[SPRITES[spriteOrder[i]].tex],
						texX,
						texY,
					)
					// Only draw color if color isn't transparent
					if (rl.ColorToInt(color) & 0x00FFFFFF) != 0 do buffer[y][x] = color
				}
			}
		}
	}
}

DrawScreenTexture :: proc(screenTex: ^rl.Texture2D) {
	source: rl.Rectangle = {0, 0, f32(WIN_WIDTH), f32(WIN_HEIGHT)}
	dest: rl.Rectangle = {0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
	rl.UpdateTexture(screenTex^, &buffer)
	rl.DrawTexturePro(screenTex^, source, dest, {0, 0}, 0, rl.WHITE)
}

DrawRays :: proc(rayStart: ^Vec2, rayEnds: ^[WIN_WIDTH]Vec2) {
	for x in 0 ..< WIN_WIDTH {
		rl.DrawLineV(rayStart^ * f32(SCALER), rayEnds^[x] * f32(SCALER), rl.DARKBROWN)
	}
}

