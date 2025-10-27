extends Node2D

# 店の入口マーカー

var grid_position: Vector2i

func _init(pos: Vector2i):
	grid_position = pos
	add_to_group("shop_entrances")
