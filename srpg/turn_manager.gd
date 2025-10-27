extends Node

signal turn_ended

func process_turn():
	# 魔法選択中は処理しない
	var magic_selector = get_tree().root.find_child("MagicSelector", true, false)
	if magic_selector and magic_selector.is_active:
		print("魔法選択中のためターン処理スキップ")
		return

	# プレイヤーのターンが終わったので敵のターン開始
	emit_signal("turn_ended")

	# 全ての敵を動かす
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("take_turn"):
			enemy.take_turn()
