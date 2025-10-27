extends Node2D

const GRID_SIZE = 64
const GRID_DEPTH = 5  # 奥行き
const CHUNK_SIZE = 20  # チャンクサイズ(横20マス)
const PRELOAD_CHUNKS = 3  # 先読みチャンク数

@onready var grid_highlight = $GridHighlight
@onready var ground_layer = $GroundLayer
@onready var overlay_layer = $OverlayLayer

var hole_positions = []  # 穴の位置を記録
var shop_positions = []  # 店の位置を記録
var enemy_scene = preload("res://characters/enemy.tscn")
var loaded_chunks = {}  # チャンクの辞書 {chunk_id: true}
var rightmost_chunk = -1  # 最も右のチャンクID
var previous_tiles = []  # 前の列のタイル情報

func _ready():
	add_to_group("field")
	# 初期タイル情報(最初の列は全部タイル)
	for y in range(GRID_DEPTH):
		previous_tiles.append(true)

	setup_tiles()
	draw_grid()

func setup_tiles():
	# 初期チャンクを生成(0~2の3チャンク分)
	for chunk_id in range(PRELOAD_CHUNKS):
		generate_chunk(chunk_id)

func generate_chunk(chunk_id: int):
	"""チャンクを生成"""
	if chunk_id in loaded_chunks:
		return  # 既に生成済み

	var start_x = chunk_id * CHUNK_SIZE
	var end_x = start_x + CHUNK_SIZE

	generate_tiles(start_x, end_x)
	spawn_shops_in_range(start_x, end_x)
	spawn_enemies_in_range(start_x, end_x)

	loaded_chunks[chunk_id] = true
	if chunk_id > rightmost_chunk:
		rightmost_chunk = chunk_id

func check_and_generate_chunks(player_x: int):
	"""プレイヤー位置に応じてチャンクを生成"""
	var player_chunk = int(player_x / CHUNK_SIZE)

	# 先読み分のチャンクを生成
	for i in range(PRELOAD_CHUNKS):
		var chunk_id = player_chunk + i
		generate_chunk(chunk_id)

	# 古いチャンクを削除(メモリ節約、プレイヤーから3チャンク以上離れたもの)
	var chunks_to_remove = []
	for chunk_id in loaded_chunks.keys():
		if chunk_id < player_chunk - 3:
			chunks_to_remove.append(chunk_id)

	for chunk_id in chunks_to_remove:
		unload_chunk(chunk_id)

func unload_chunk(chunk_id: int):
	"""チャンクをアンロード"""
	var start_x = chunk_id * CHUNK_SIZE
	var end_x = start_x + CHUNK_SIZE

	# タイルを削除
	for x in range(start_x, end_x):
		for y in range(GRID_DEPTH):
			ground_layer.erase_cell(Vector2i(x, y))
			overlay_layer.erase_cell(Vector2i(x, y))

	loaded_chunks.erase(chunk_id)

func spawn_shops_in_range(start_x: int, end_x: int):
	"""指定範囲に店を配置(10マスごとに20%の確率)"""
	var first_shop_x = ceili(start_x / 10.0) * 10
	for x in range(first_shop_x, end_x, 10):
		if randf() < 0.2:  # 20%の確率で店
			var shop_y = randi_range(0, GRID_DEPTH - 1)
			var cell_id = ground_layer.get_cell_source_id(Vector2i(x, shop_y))
			if cell_id != -1:
				shop_positions.append(Vector2i(x, shop_y))
				overlay_layer.set_cell(Vector2i(x, shop_y), 0, Vector2i(1, 0))  # 青(店)タイル

func spawn_enemies_in_range(start_x: int, end_x: int):
	"""指定範囲に敵を配置(チャンクあたり2~4体)"""
	var enemy_count = randi_range(2, 4)
	for i in range(enemy_count):
		var enemy_x = randi_range(start_x, end_x - 1)
		var enemy_y = randi_range(0, GRID_DEPTH - 1)

		var cell_id = ground_layer.get_cell_source_id(Vector2i(enemy_x, enemy_y))
		if cell_id == -1:
			continue  # 穴なのでスキップ

		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.set_grid_position(Vector2i(enemy_x, enemy_y))

func generate_tiles(start_x: int, end_x: int):
	# 指定範囲のタイルを自動生成
	var prev_tiles = []

	# 前の列の状態を取得
	if start_x == 0:
		# 最初の列は全部タイル
		prev_tiles = previous_tiles.duplicate()
	else:
		# 既存のタイルから取得
		for y in range(GRID_DEPTH):
			var cell_id = ground_layer.get_cell_source_id(Vector2i(start_x - 1, y))
			prev_tiles.append(cell_id != -1)

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
			if prev_tiles[y] and tiles_to_place[y]:
				has_connection = true
				break

		# 接続がない場合、前の列のタイルと繋がる位置に1つ配置
		if not has_connection:
			var valid_positions = []
			for y in range(GRID_DEPTH):
				if prev_tiles[y]:
					valid_positions.append(y)

			if valid_positions.size() > 0:
				var connect_y = valid_positions[randi() % valid_positions.size()]
				tiles_to_place[connect_y] = true

		# タイルを配置
		for y in range(GRID_DEPTH):
			if tiles_to_place[y]:
				# ランダムなタイル座標を選択(4x4のタイルセットから)
				var tile_x = randi_range(0, 3)
				var tile_y = randi_range(0, 3)
				ground_layer.set_cell(Vector2i(x, y), 0, Vector2i(tile_x, tile_y))
			else:
				# 穴の位置を記録して、オーバーレイに赤タイル配置
				hole_positions.append(Vector2i(x, y))
				overlay_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))  # 赤(穴)タイル

		# 次の列のために記録
		prev_tiles = tiles_to_place
		if x == end_x - 1:
			previous_tiles = tiles_to_place

func _draw():
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
