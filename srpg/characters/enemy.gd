extends Node2D

const GRID_SIZE = 64
const SPRITE_OFFSET = Vector2(0, -30)
const GRID_DEPTH = 5

var grid_position = Vector2i(0, 0)

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	position = grid_to_pixel(grid_position)
	animated_sprite.play("walk")

func set_grid_position(pos: Vector2i):
	grid_position = pos
	position = grid_to_pixel(grid_position)

func take_turn():
	# プレイヤーの位置を取得
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# プレイヤーに近づく方向を決定
	var direction = Vector2i.ZERO
	var dx = player.grid_position.x - grid_position.x
	var dy = player.grid_position.y - grid_position.y

	# X方向優先で移動
	if abs(dx) > abs(dy):
		direction.x = 1 if dx > 0 else -1
	else:
		direction.y = 1 if dy > 0 else -1

	var new_pos = grid_position + direction

	# 移動可能かチェック
	if can_move_to(new_pos):
		grid_position = new_pos
		position = grid_to_pixel(grid_position)

func can_move_to(grid_pos: Vector2i) -> bool:
	# 範囲チェック
	if grid_pos.y < 0 or grid_pos.y >= GRID_DEPTH:
		return false
	if grid_pos.x < 0:
		return false

	# 地形チェック
	var field = get_tree().get_first_node_in_group("field")
	if field and field.has_node("GroundLayer"):
		var ground_layer = field.get_node("GroundLayer")
		var cell_source_id = ground_layer.get_cell_source_id(grid_pos)
		if cell_source_id == -1:
			return false

	# 他の敵がいないかチェック
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy != self and enemy.grid_position == grid_pos:
			return false

	# プレイヤーがいないかチェック
	var player = get_tree().get_first_node_in_group("player")
	if player and player.grid_position == grid_pos:
		return false

	return true

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * GRID_SIZE + GRID_SIZE / 2.0, grid_pos.y * GRID_SIZE + GRID_SIZE / 2.0) + SPRITE_OFFSET
