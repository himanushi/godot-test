extends Node2D

@onready var camera = $Camera2D
@onready var player = $Characters/Player

const CAMERA_SPEED = 400.0  # カメラオフセット調整速度

var camera_offset_x = 0.0  # カメラのXオフセット

func _process(delta):
	if not player:
		return

	# カメラオフセットをキー操作で調整
	var camera_input = 0.0
	if Input.is_action_pressed("ui_page_down"):  # E (右にずらす)
		camera_input = 1.0
	elif Input.is_action_pressed("ui_page_up"):  # Q (左にずらす)
		camera_input = -1.0

	# オフセットを更新
	camera_offset_x += camera_input * CAMERA_SPEED * delta

	# カメラはプレイヤー位置 + オフセット
	camera.position.x = player.position.x + camera_offset_x
