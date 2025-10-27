extends CharacterBody2D

const GRID_SIZE = 64
const SPRITE_OFFSET = Vector2(0, -30)

var grid_position = Vector2i(0, 0)

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	position = grid_to_pixel(grid_position)
	animated_sprite.play("walk")

func set_grid_position(pos: Vector2i):
	grid_position = pos
	position = grid_to_pixel(grid_position)

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * GRID_SIZE + GRID_SIZE / 2.0, grid_pos.y * GRID_SIZE + GRID_SIZE / 2.0) + SPRITE_OFFSET
