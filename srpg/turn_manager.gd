extends Node

signal turn_ended

func process_turn():
	# プレイヤーのターンが終わったので敵のターン開始
	emit_signal("turn_ended")

	# 全ての敵を動かす
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("take_turn"):
			enemy.take_turn()
