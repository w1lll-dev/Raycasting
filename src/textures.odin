#+feature dynamic-literals
package main

import rl "vendor:raylib"

@(rodata)
TEXTURE_PATHS := [?]cstring {
	// Environment textures
	"resources/wall1.png",
	"resources/wall2.png",
	"resources/wall3.png",
	"resources/wall4.png",
	"resources/floor.png",
	"resources/ceiling.png",

	// Sprite textures
	"resources/container.png",
	"resources/robot.png",
}

InitTextures :: proc() -> [len(TEXTURE_PATHS)]rl.Image {
	textures: [len(TEXTURE_PATHS)]rl.Image
	for i in 0 ..< len(TEXTURE_PATHS) {
		textures[i] = rl.LoadImage(TEXTURE_PATHS[i])
	}
	return textures
}

InitTextureMap :: proc(textures: ^[len(TEXTURE_PATHS)]rl.Image) -> map[rl.Color]rl.Image {
	return {
		rl.GRAY = textures[0],
		rl.DARKGRAY = textures[1],
		rl.LIGHTGRAY = textures[2],
		rl.SKYBLUE = textures[3],
	}
}

