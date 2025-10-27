extends CharacterBody2D

const GRID_SIZE = 64  # マス目のサイズ(ピクセル)
const MOVE_SPEED = 300.0  # 移動速度

var grid_position = Vector2i(0, 0)  # グリッド座標
var target_position = Vector2.ZERO  # 目標位置
var is_moving = false
var move_direction = Vector2i.ZERO  # 現在の移動方向

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# 初期位置をグリッドに合わせる
	position = grid_to_pixel(grid_position)
	target_position = position
	animated_sprite.play("idle")

func _process(delta):
	# 入力チェック
	if not is_moving:
		check_input()

	if is_moving:
		# 目標位置に向かって移動
		position = position.move_toward(target_position, MOVE_SPEED * delta)
		if position.distance_to(target_position) < 1.0:
			position = target_position
			is_moving = false
			# 移動完了後、キーが押されていれば次のマスへ
			check_input()

func check_input():
	var direction = Vector2i.ZERO

	if Input.is_action_pressed("ui_right"):
		direction = Vector2i(1, 0)
		animated_sprite.play("right_run")
		animated_sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		direction = Vector2i(-1, 0)
		animated_sprite.play("right_run")
		animated_sprite.flip_h = true
	elif Input.is_action_pressed("ui_down"):
		direction = Vector2i(0, 1)
		animated_sprite.play("idle")
	elif Input.is_action_pressed("ui_up"):
		direction = Vector2i(0, -1)
		animated_sprite.play("idle")
	else:
		animated_sprite.play("idle")

	if direction != Vector2i.ZERO:
		move_to_grid(grid_position + direction)
		move_direction = direction
	else:
		move_direction = Vector2i.ZERO

func move_to_grid(new_grid_pos: Vector2i):
	# グリッドの範囲チェック(奥行き5マスまで)
	if new_grid_pos.y < 0 or new_grid_pos.y >= 5:
		return

	# 左端は移動不可
	if new_grid_pos.x < 0:
		return

	grid_position = new_grid_pos
	target_position = grid_to_pixel(grid_position)
	is_moving = true

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * GRID_SIZE, grid_pos.y * GRID_SIZE)
