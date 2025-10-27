extends Node

# MagicSelectorの入力処理を管理

var magic_selector = null

func _ready():
	set_process_input(true)

func _input(event):
	# MagicSelectorを探す
	if not magic_selector:
		magic_selector = get_tree().root.find_child("MagicSelector", true, false)

	if not magic_selector or not magic_selector.is_active:
		return

	# 魔法モード中の入力
	if event.is_action_pressed("ui_right"):
		magic_selector.move_cursor(Vector2i(1, 0))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		magic_selector.move_cursor(Vector2i(-1, 0))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		magic_selector.move_cursor(Vector2i(0, 1))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		magic_selector.move_cursor(Vector2i(0, -1))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		magic_selector.confirm_selection()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		magic_selector.cancel_selection()
		get_viewport().set_input_as_handled()
