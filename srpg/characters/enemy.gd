extends Node2D

const GRID_SIZE = 64
const SPRITE_OFFSET = Vector2(0, -30)
const GRID_DEPTH = 5

var grid_position = Vector2i(0, 0)

# ステータス
var max_hp = 50
var hp = 50
var attack_power = 8
var defense = 3
var speed = 5
var move_power = 2

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

	# プレイヤーとの距離をチェック
	var distance = abs(player.grid_position.x - grid_position.x) + abs(player.grid_position.y - grid_position.y)

	# 隣接していれば攻撃
	if distance == 1:
		# 攻撃方向を計算
		var direction = Vector2i(
			sign(player.grid_position.x - grid_position.x),
			sign(player.grid_position.y - grid_position.y)
		)
		# 攻撃アニメーション
		perform_attack_animation(direction)
		await get_tree().create_timer(0.2).timeout
		attack(player)
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

func attack(target):
	"""攻撃処理"""
	if not target or target.hp <= 0:
		return

	# ダメージ計算: 攻撃力 - 防御力(最低1ダメージ)
	var damage = max(1, attack_power - target.defense)
	target.take_damage(damage)
	print(name, " が ", target.name, " に ", damage, " ダメージ!")

func take_damage(damage: int):
	"""ダメージを受ける"""
	hp -= damage
	if hp <= 0:
		hp = 0
		die()
	print(name, " が ", damage, " ダメージを受けた! (残りHP: ", hp, ")")

func die():
	"""死亡処理"""
	print(name, " は倒れた...")
	queue_free()  # 敵は消滅

func perform_attack_animation(direction: Vector2i):
	"""攻撃アニメーション: 少し前に移動"""
	var push_distance = 16  # 移動距離(ピクセル)
	var original_pos = position
	var push_pos = position + Vector2(direction.x * push_distance, direction.y * push_distance)

	# 前に移動
	var tween = create_tween()
	tween.tween_property(self, "position", push_pos, 0.1)
	tween.tween_property(self, "position", original_pos, 0.1)
