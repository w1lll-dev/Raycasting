package main

Vec2 :: [2]f32
Vec2i :: [2]i32

Vec2ToVec2i :: proc(vec: Vec2) -> Vec2i {
	return Vec2i{i32(vec.x), i32(vec.y)}
}

Vec2iToVec2 :: proc(vec: Vec2i) -> Vec2 {
	return Vec2{f32(vec.x), f32(vec.y)}
}

