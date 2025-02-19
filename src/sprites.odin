package main

import "core:slice"

Sprite :: struct {
	pos: Vec2,
	tex: i32,
}

FloatIntPair :: struct {
	floatVal: f32,
	intVal:   i32,
}

@(rodata)
SPRITES := [?]Sprite {
	// Containers
	{pos = {1.5, 1.5}, tex = 6},
	{pos = {5.5, 13.5}, tex = 6},
	{pos = {8.5, 13.5}, tex = 6},
	// Enemies
	{pos = {7, 3}, tex = 7},
	{pos = {7, 6}, tex = 7},
}

spriteOrder: [len(SPRITES)]i32
spriteDist: [len(SPRITES)]f32

FloatLessThanInt :: proc(pairA, pairB: FloatIntPair) -> bool {
	return pairA.floatVal < pairB.floatVal && pairA.intVal < pairB.intVal
}

// Sort sprites based on distance
SortSprites :: proc(order: ^[len(SPRITES)]i32, dist: ^[len(SPRITES)]f32) {
	sprites := make_slice([]FloatIntPair, len(SPRITES))

	for i in 0 ..< len(SPRITES) {
		sprites[i] = {dist^[i], order^[i]}
	}

	slice.sort_by(sprites, proc(pairA, pairB: FloatIntPair) -> bool {
		if pairA.floatVal < pairB.floatVal do return true
		if pairA.floatVal > pairB.floatVal do return false
		return pairA.intVal < pairB.intVal
	})

	// Restore in reverse order to go from farthest to nearest
	for i in 0 ..< len(SPRITES) {
		dist[i] = sprites[len(SPRITES) - i - 1].floatVal
		order[i] = sprites[len(SPRITES) - i - 1].intVal
	}
}

