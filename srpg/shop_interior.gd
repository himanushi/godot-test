extends CanvasLayer

# 店内システム

const GRID_SIZE = 64
const SHOP_WIDTH = 5
const SHOP_HEIGHT = 5

@onready var panel = $Panel
@onready var grid_container = $Panel/VBoxContainer/GridContainer
@onready var exit_button = $Panel/VBoxContainer/ExitButton
@onready var player_sprite = $Panel/VBoxContainer/GridContainer/PlayerSprite
@onready var shopkeeper_sprite = $Panel/VBoxContainer/GridContainer/ShopkeeperSprite

var player = null
var shop_keeper_pos = Vector2i(2, 0)  # 店主の位置(上中央)
var entrance_pos = Vector2i(2, 4)  # 入口の位置(下中央)
var player_shop_pos = Vector2i(2, 4)  # プレイヤーの店内位置

var is_open = false
var tiles = []  # 店内のタイルUI
var character_sprites = []  # キャラクタースプライト

func _ready():
	hide_shop()
	exit_button.pressed.connect(_on_exit_button_pressed)
	setup_shop_grid()

func setup_shop_grid():
	"""店内グリッドのセットアップ"""
	grid_container.columns = SHOP_WIDTH

	for y in range(SHOP_HEIGHT):
		for x in range(SHOP_WIDTH):
			var container = Control.new()
			container.custom_minimum_size = Vector2(60, 60)

			# 背景パネル
			var tile = Panel.new()
			tile.set_anchors_preset(Control.PRESET_FULL_RECT)
			var style = StyleBoxFlat.new()
			if Vector2i(x, y) == entrance_pos:
				style.bg_color = Color(0.5, 0.5, 1)  # 青(入口)
			else:
				style.bg_color = Color(0.8, 0.8, 0.8)  # グレー(床)
			tile.add_theme_stylebox_override("panel", style)
			container.add_child(tile)

			# キャラクタースプライト
			var sprite = ColorRect.new()
			sprite.custom_minimum_size = Vector2(50, 50)
			sprite.position = Vector2(5, 5)
			sprite.visible = false
			container.add_child(sprite)
			character_sprites.append(sprite)

			grid_container.add_child(container)
			tiles.append(tile)

func show_shop():
	"""店を表示"""
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	is_open = true
	panel.visible = true
	player_shop_pos = entrance_pos
	update_player_position()

func hide_shop():
	"""店を非表示"""
	is_open = false
	panel.visible = false

func update_player_position():
	"""プレイヤー位置を更新"""
	# 全キャラクタースプライトをリセット
	for i in range(character_sprites.size()):
		var x = i % SHOP_WIDTH
		var y = i / SHOP_WIDTH
		var pos = Vector2i(x, y)
		var sprite = character_sprites[i]

		if pos == player_shop_pos:
			sprite.visible = true
			sprite.color = Color(0, 1, 0)  # 緑(プレイヤー)
		elif pos == shop_keeper_pos:
			sprite.visible = true
			sprite.color = Color(1, 0.5, 0)  # オレンジ(店主)
		else:
			sprite.visible = false

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
		var new_pos = player_shop_pos + direction
		# 範囲チェック
		if new_pos.x >= 0 and new_pos.x < SHOP_WIDTH and new_pos.y >= 0 and new_pos.y < SHOP_HEIGHT:
			# 店主の位置は移動不可
			if new_pos != shop_keeper_pos:
				player_shop_pos = new_pos
				update_player_position()

func is_adjacent_to_shopkeeper() -> bool:
	"""店主に隣接しているか"""
	var distance = abs(player_shop_pos.x - shop_keeper_pos.x) + abs(player_shop_pos.y - shop_keeper_pos.y)
	return distance == 1

func open_shop_menu():
	"""店メニューを開く"""
	var shop_menu = get_tree().root.find_child("ShopMenu", true, false)
	if shop_menu and shop_menu.has_method("show_menu"):
		shop_menu.show_menu()

func _on_exit_button_pressed():
	"""店を出る"""
	hide_shop()
	# プレイヤーを再表示
	if player and player.has_method("show_player"):
		player.show_player()
