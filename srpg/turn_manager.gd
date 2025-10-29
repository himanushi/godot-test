extends Node

signal turn_ended

var is_processing = false  # ターン処理中フラグ

func process_turn():
	# 既に処理中なら何もしない
	if is_processing:
		return

	# 魔法選択中は処理しない
	var magic_selector = get_tree().root.find_child("MagicSelector", true, false)
	if magic_selector and magic_selector.is_active:
		print("魔法選択中のためターン処理スキップ")
		return

	is_processing = true

	# プレイヤーのターンが終わったので敵のターン開始
	emit_signal("turn_ended")

	# 全ての敵を順番に動かす
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("take_turn"):
			await enemy.take_turn()
			# 各敵の行動後に少し待機
			await get_tree().create_timer(0.1).timeout

	is_processing = false
