extends Node2D

# 魔法の範囲選択システム

const GRID_SIZE = 64

var is_active = false
var caster = null
var magic: Magic = null
var cursor_pos: Vector2i = Vector2i.ZERO
var valid_positions: Array = []

signal magic_cast(target_pos: Vector2i)

func start_selection(from_character, using_magic: Magic):
	"""範囲選択開始"""
	caster = from_character
	magic = using_magic
	is_active = true
	cursor_pos = caster.grid_position

	# 範囲内の有効な位置を計算
	calculate_valid_positions()

	queue_redraw()

func calculate_valid_positions():
	"""有効な位置を計算"""
	valid_positions.clear()

	for x in range(-magic.range, magic.range + 1):
		for y in range(-magic.range, magic.range + 1):
			var distance = abs(x) + abs(y)
			if distance > 0 and distance <= magic.range:
				var pos = caster.grid_position + Vector2i(x, y)
				# 範囲チェック
				if pos.y >= 0 and pos.y < 5:
					valid_positions.append(pos)

func move_cursor(direction: Vector2i):
	"""カーソル移動"""
	var new_pos = cursor_pos + direction

	# 有効な位置のみ移動可能
	if new_pos in valid_positions:
		cursor_pos = new_pos
		queue_redraw()

func confirm_selection():
	"""選択確定"""
	if cursor_pos in valid_positions:
		is_active = false
		print("魔法選択確定: ", cursor_pos)
		emit_signal("magic_cast", cursor_pos)
		queue_redraw()
	else:
		print("範囲外です")

func cancel_selection():
	"""選択キャンセル"""
	is_active = false
	print("魔法選択キャンセル")
	queue_redraw()

func _draw():
	if not is_active:
		return

	# 範囲内のマスを青く表示
	for pos in valid_positions:
		var rect = Rect2(pos.x * GRID_SIZE, pos.y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
		draw_rect(rect, Color(0.3, 0.5, 1.0, 0.3))

	# カーソル位置を黄色で表示
	var cursor_rect = Rect2(cursor_pos.x * GRID_SIZE, cursor_pos.y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
	draw_rect(cursor_rect, Color(1.0, 1.0, 0.0, 0.5))
