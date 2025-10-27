extends Node2D

@onready var camera = $Camera2D
@onready var player = $Characters/Player

const CAMERA_OFFSET = 200.0  # カメラのオフセット量

var target_offset = 0.0
var current_offset = 0.0

func _process(delta):
	if not player:
		return

	# プレイヤーの移動方向を取得
	var move_dir = player.move_direction

	# 移動方向に応じてオフセットを設定
	if move_dir.x > 0:  # 右に移動中
		target_offset = CAMERA_OFFSET  # カメラを右にずらす(プレイヤーは左側に)
	elif move_dir.x < 0:  # 左に移動中
		target_offset = -CAMERA_OFFSET  # カメラを左にずらす(プレイヤーは右側に)
	# それ以外(停止中・上下移動)は現在のオフセットを維持

	# スムーズにオフセットを変更
	current_offset = lerp(current_offset, target_offset, 1.5 * delta)

	# カメラのX座標をプレイヤー + オフセット
	camera.position.x = player.position.x + current_offset
