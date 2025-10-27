extends Node2D

@onready var camera = $Camera2D
@onready var player = $Characters/Player

func _process(_delta):
	# カメラのX座標だけプレイヤーに追従
	camera.position.x = player.position.x
