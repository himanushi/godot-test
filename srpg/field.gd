extends Node2D

const GRID_SIZE = 64
const GRID_DEPTH = 5  # 奥行き

@onready var grid_highlight = $GridHighlight
@onready var ground_layer = $GroundLayer

var hole_positions = []  # 穴の位置を記録
var enemy_scene = preload("res://characters/enemy.tscn")

func _ready():
	setup_tiles()
	spawn_enemies()
	draw_grid()

func setup_tiles():
	# 初期タイルを配置(横100マス分)
	generate_tiles(0, 100)

func spawn_enemies():
	# 敵を配置(10~90の範囲でランダムに10体)
	for i in range(10):
		var enemy_x = randi_range(10, 90)
		var enemy_y = randi_range(0, GRID_DEPTH - 1)

		# そのマスにタイルがあるかチェック
		var cell_id = ground_layer.get_cell_source_id(Vector2i(enemy_x, enemy_y))
		if cell_id == -1:
			continue  # 穴なのでスキップ

		# 敵を生成
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.set_grid_position(Vector2i(enemy_x, enemy_y))

func generate_tiles(start_x: int, end_x: int):
	# 指定範囲のタイルを自動生成
	var previous_tiles = []

	# 最初の列は全部タイル
	if start_x == 0:
		for y in range(GRID_DEPTH):
			previous_tiles.append(true)
	else:
		# 既存のタイルから取得
		for y in range(GRID_DEPTH):
			var cell_id = ground_layer.get_cell_source_id(Vector2i(start_x - 1, y))
			previous_tiles.append(cell_id != -1)

	for x in range(start_x, end_x):
		var tiles_to_place = []

		# 各マスでタイル配置判定
		for y in range(GRID_DEPTH):
			if randf() < 0.15:  # 15%の確率で穴
				tiles_to_place.append(false)
			else:
				tiles_to_place.append(true)

		# 前の列と接続できるかチェック
		var has_connection = false
		for y in range(GRID_DEPTH):
			if previous_tiles[y] and tiles_to_place[y]:
				has_connection = true
				break

		# 接続がない場合、前の列のタイルと繋がる位置に1つ配置
		if not has_connection:
			var valid_positions = []
			for y in range(GRID_DEPTH):
				if previous_tiles[y]:
					valid_positions.append(y)

			if valid_positions.size() > 0:
				var connect_y = valid_positions[randi() % valid_positions.size()]
				tiles_to_place[connect_y] = true

		# タイルを配置
		for y in range(GRID_DEPTH):
			if tiles_to_place[y]:
				ground_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			else:
				# 穴の位置を記録
				hole_positions.append(Vector2i(x, y))

		# 次の列のために記録
		previous_tiles = tiles_to_place

func _draw():
	# 穴を赤く塗る
	for hole_pos in hole_positions:
		var rect = Rect2(hole_pos.x * GRID_SIZE, hole_pos.y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
		draw_rect(rect, Color(0.8, 0.2, 0.2, 0.5))  # 赤色、半透明

	# グリッド線を描画
	for y in range(GRID_DEPTH + 1):
		var start = Vector2(0, y * GRID_SIZE)
		var end = Vector2(1000, y * GRID_SIZE)  # 横に長く
		draw_line(start, end, Color(1, 1, 1, 0.3), 1.0)

	for x in range(15):  # 画面内に表示されるグリッド数
		var start = Vector2(x * GRID_SIZE, 0)
		var end = Vector2(x * GRID_SIZE, GRID_DEPTH * GRID_SIZE)
		draw_line(start, end, Color(1, 1, 1, 0.3), 1.0)

func draw_grid():
	queue_redraw()
