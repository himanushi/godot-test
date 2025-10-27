extends CanvasLayer

# 店内システム(TileMapLayer使用)

const GRID_SIZE = 64
const SHOP_WIDTH = 5
const SHOP_HEIGHT = 5

@onready var panel = $Panel
@onready var shop_map = $Panel/ShopMap
@onready var exit_button = $Panel/ExitButton

var player = null
var shop_player = null  # 店内のプレイヤーキャラ
var shopkeeper = null  # 店主
var shop_keeper_pos = Vector2i(2, 0)  # 店主の位置(上中央)
var entrance_pos = Vector2i(2, 4)  # 入口の位置(下中央)

var is_open = false
var player_scene = preload("res://characters/player.tscn")

func _ready():
	hide_shop()
	exit_button.pressed.connect(_on_exit_button_pressed)
	setup_shop_interior()

func setup_shop_interior():
	"""店内マップのセットアップ"""
	# ShopMapノードを作成
	if not shop_map:
		shop_map = Node2D.new()
		shop_map.name = "ShopMap"
		panel.add_child(shop_map)
		panel.move_child(shop_map, 0)  # 最背面に

	# グリッド描画用
	shop_map.draw.connect(_draw_shop_grid)

	# TileMapLayerを作成
	var tile_layer = TileMapLayer.new()
	tile_layer.name = "GroundLayer"
	shop_map.add_child(tile_layer)

	# タイルセットを設定(メインフィールドと同じものを使用)
	var main_field = get_tree().get_first_node_in_group("field")
	if main_field and main_field.has_node("GroundLayer"):
		var main_layer = main_field.get_node("GroundLayer")
		tile_layer.tile_set = main_layer.tile_set

	# 5x5のタイルを配置
	for y in range(SHOP_HEIGHT):
		for x in range(SHOP_WIDTH):
			tile_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

	# 店主を配置
	shopkeeper = ColorRect.new()
	shopkeeper.name = "Shopkeeper"
	shopkeeper.custom_minimum_size = Vector2(40, 60)
	shopkeeper.color = Color(1, 0.5, 0)  # オレンジ
	shopkeeper.position = Vector2(shop_keeper_pos.x * GRID_SIZE + 12, shop_keeper_pos.y * GRID_SIZE + 2)
	shop_map.add_child(shopkeeper)

	# カメラ位置調整
	shop_map.position = Vector2(50, 50)

func _draw_shop_grid():
	"""店内グリッド描画"""
	# グリッド線を描画
	for y in range(SHOP_HEIGHT + 1):
		var start = Vector2(0, y * GRID_SIZE)
		var end = Vector2(SHOP_WIDTH * GRID_SIZE, y * GRID_SIZE)
		shop_map.draw_line(start, end, Color(1, 1, 1, 0.3), 1.0)

	for x in range(SHOP_WIDTH + 1):
		var start = Vector2(x * GRID_SIZE, 0)
		var end = Vector2(x * GRID_SIZE, SHOP_HEIGHT * GRID_SIZE)
		shop_map.draw_line(start, end, Color(1, 1, 1, 0.3), 1.0)

func show_shop():
	"""店を表示"""
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	is_open = true
	panel.visible = true

	# 店内プレイヤーを作成(プレイヤーシーンを使用)
	if not shop_player:
		shop_player = player_scene.instantiate()
		shop_player.name = "ShopPlayer"
		# プレイヤーの入力を無効化
		shop_player.set_process(false)
		shop_map.add_child(shop_player)

	# 入口に配置
	var pixel_pos = Vector2(entrance_pos.x * GRID_SIZE + GRID_SIZE / 2.0, entrance_pos.y * GRID_SIZE + GRID_SIZE / 2.0)
	shop_player.position = pixel_pos
	shop_player.visible = true

	# グリッド描画
	shop_map.queue_redraw()

func hide_shop():
	"""店を非表示"""
	is_open = false
	panel.visible = false
	if shop_player:
		shop_player.visible = false

func _input(event):
	if not is_open:
		return

	# 店内での移動
	var direction = Vector2i.ZERO
	if event.is_action_pressed("ui_right"):
		direction = Vector2i(1, 0)
	elif event.is_action_pressed("ui_left"):
		direction = Vector2i(-1, 0)
	elif event.is_action_pressed("ui_down"):
		direction = Vector2i(0, 1)
	elif event.is_action_pressed("ui_up"):
		direction = Vector2i(0, -1)
	elif event.is_action_pressed("ui_accept"):
		# 店主に話しかける
		if is_adjacent_to_shopkeeper():
			open_shop_menu()
		return

	if direction != Vector2i.ZERO:
		move_shop_player(direction)

func move_shop_player(direction: Vector2i):
	"""店内プレイヤーを移動"""
	if not shop_player:
		return

	# 現在位置を計算
	var current_pos = Vector2i(
		int((shop_player.position.x - GRID_SIZE / 2.0) / GRID_SIZE),
		int((shop_player.position.y - GRID_SIZE / 2.0) / GRID_SIZE)
	)

	var new_pos = current_pos + direction

	# 範囲チェック
	if new_pos.x < 0 or new_pos.x >= SHOP_WIDTH or new_pos.y < 0 or new_pos.y >= SHOP_HEIGHT:
		return

	# 店主の位置は移動不可
	if new_pos == shop_keeper_pos:
		print("店主が邪魔で進めない")
		return

	# 移動
	var pixel_pos = Vector2(new_pos.x * GRID_SIZE + GRID_SIZE / 2.0, new_pos.y * GRID_SIZE + GRID_SIZE / 2.0)
	shop_player.position = pixel_pos
	print("店内移動: ", new_pos)

func is_adjacent_to_shopkeeper() -> bool:
	"""店主に隣接しているか"""
	if not shop_player:
		return false

	var player_pos = Vector2i(
		int((shop_player.position.x - GRID_SIZE / 2.0) / GRID_SIZE),
		int((shop_player.position.y - GRID_SIZE / 2.0) / GRID_SIZE)
	)

	var distance = abs(player_pos.x - shop_keeper_pos.x) + abs(player_pos.y - shop_keeper_pos.y)
	return distance == 1

func open_shop_menu():
	"""店メニューを開く"""
	print("店主と会話!")
	var shop_menu = get_tree().root.find_child("ShopMenu", true, false)
	if shop_menu and shop_menu.has_method("show_menu"):
		shop_menu.show_menu()

func _on_exit_button_pressed():
	"""店を出る"""
	hide_shop()
	# プレイヤーを再表示
	if player and player.has_method("show_player"):
		player.show_player()
