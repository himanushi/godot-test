extends Node2D

const GRID_SIZE = 64  # マス目のサイズ(ピクセル)
const MOVE_SPEED = 600.0  # 移動速度
const SPRITE_OFFSET = Vector2(0, -30)  # スプライト表示用オフセット

# クラスの事前読み込み
const FireMagic = preload("res://magics/fire_magic.gd")
const SpriteLoader = preload("res://sprite_loader.gd")

var grid_position = Vector2i(0, 0)  # グリッド座標
var target_position = Vector2.ZERO  # 目標位置
var is_moving = false
var move_direction = Vector2i.ZERO  # 現在の移動方向
var last_horizontal_direction = 1  # 最後の左右方向(1=右, -1=左)

# ステータス
var max_hp = 100
var hp = 100
var attack_power = 10
var defense = 5
var speed = 10
var move_power = 3
var max_mp = 50
var mp = 50

# インベントリ
var inventory: Inventory

# 魔法
var fire_magic: FireMagic

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# 初期位置をグリッドに合わせる
	position = grid_to_pixel(grid_position)
	target_position = position
	animated_sprite.play("idle")

	# スプライトの背景を透明化
	apply_sprite_transparency()

	# インベントリ初期化
	inventory = Inventory.new()
	add_child(inventory)

	# 魔法初期化
	fire_magic = FireMagic.new()

func apply_sprite_transparency():
	"""スプライトの背景色を透明化"""
	if animated_sprite and animated_sprite.sprite_frames:
		# 茶色の背景を透明に
		var bg_color = Color(0.545, 0.42, 0.29, 1.0)

		# 全アニメーションに適用
		var animations = animated_sprite.sprite_frames.get_animation_names()
		for anim_name in animations:
			SpriteLoader.apply_transparency_to_sprite_frames(
				animated_sprite.sprite_frames,
				anim_name,
				bg_color
			)

func _process(delta):
	# 店内では入力を受け付けない
	var shop_interior = get_tree().root.find_child("ShopInterior", true, false)
	if shop_interior and shop_interior.is_open:
		return

	# 魔法選択中は入力を受け付けない
	var magic_selector = get_tree().root.find_child("MagicSelector", true, false)
	if magic_selector and magic_selector.is_active:
		return

	# 入力チェック
	if not is_moving:
		check_input()

	if is_moving:
		# 目標位置に向かって移動
		position = position.move_toward(target_position, MOVE_SPEED * delta)
		if position.distance_to(target_position) < 1.0:
			position = target_position
			is_moving = false
			# ターン処理を実行
			var turn_manager = get_tree().get_first_node_in_group("turn_manager")
			if turn_manager and turn_manager.has_method("process_turn"):
				turn_manager.process_turn()

func check_input():
	var direction = Vector2i.ZERO

	# 魔法モード - Mキー
	if Input.is_action_just_pressed("cast_magic"):
		start_magic_mode()
		return

	# アイテムメニュー - Iキー
	if Input.is_action_just_pressed("open_item_menu"):
		open_item_menu()
		return

	# 足踏み(待機) - Zキーまたは.(ピリオド)
	if Input.is_action_just_pressed("wait_turn"):
		wait_turn()
		return

	# 攻撃モード(スペースキー押下中)
	if Input.is_action_pressed("ui_accept"):
		# 攻撃方向を方向キーで選択(pressed使用)
		if Input.is_action_pressed("ui_right"):
			print("右攻撃")
			try_attack_direction(Vector2i(1, 0))
			return
		elif Input.is_action_pressed("ui_left"):
			print("左攻撃")
			try_attack_direction(Vector2i(-1, 0))
			return
		elif Input.is_action_pressed("ui_down"):
			print("下攻撃")
			try_attack_direction(Vector2i(0, 1))
			return
		elif Input.is_action_pressed("ui_up"):
			print("上攻撃")
			try_attack_direction(Vector2i(0, -1))
			return
		return

	# 通常移動
	if Input.is_action_pressed("ui_right"):
		direction = Vector2i(1, 0)
		last_horizontal_direction = 1
		animated_sprite.play("right_run")
		animated_sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		direction = Vector2i(-1, 0)
		last_horizontal_direction = -1
		animated_sprite.play("right_run")
		animated_sprite.flip_h = true
	elif Input.is_action_pressed("ui_down"):
		direction = Vector2i(0, 1)
		# 上下移動時も走りアニメーション、向きは最後の左右を使用
		animated_sprite.play("right_run")
		animated_sprite.flip_h = (last_horizontal_direction == -1)
	elif Input.is_action_pressed("ui_up"):
		direction = Vector2i(0, -1)
		# 上下移動時も走りアニメーション、向きは最後の左右を使用
		animated_sprite.play("right_run")
		animated_sprite.flip_h = (last_horizontal_direction == -1)
	else:
		animated_sprite.play("idle")

	if direction != Vector2i.ZERO:
		move_to_grid(grid_position + direction)
		move_direction = direction
	else:
		move_direction = Vector2i.ZERO

func try_attack_direction(direction: Vector2i):
	"""指定方向の敵を攻撃"""
	var target_pos = grid_position + direction
	print("攻撃対象座標: ", target_pos)
	print("現在の自分の座標: ", grid_position)

	var enemies = get_tree().get_nodes_in_group("enemies")
	print("敵の数: ", enemies.size())

	for enemy in enemies:
		print("敵の座標: ", enemy.grid_position, " 名前: ", enemy.name)
		if enemy.grid_position == target_pos:
			print("攻撃実行!")
			# 攻撃アニメーション: 少し前に移動
			perform_attack_animation(direction)
			await get_tree().create_timer(0.2).timeout

			attack(enemy)

			# ターン終了処理
			var battle_manager = get_tree().get_first_node_in_group("battle_manager")
			if battle_manager:
				battle_manager.end_turn(self)
			else:
				# battle_managerがない場合はturn_managerを使用
				var turn_manager = get_tree().get_first_node_in_group("turn_manager")
				if turn_manager and turn_manager.has_method("process_turn"):
					turn_manager.process_turn()
			return
	print("攻撃対象がいません")

func perform_attack_animation(direction: Vector2i):
	"""攻撃アニメーション: 少し前に移動"""
	var push_distance = 16  # 移動距離(ピクセル)
	var original_pos = position
	var push_pos = position + Vector2(direction.x * push_distance, direction.y * push_distance)

	# 前に移動
	var tween = create_tween()
	tween.tween_property(self, "position", push_pos, 0.1)
	tween.tween_property(self, "position", original_pos, 0.1)

func wait_turn():
	"""足踏み(待機) - その場でターン終了"""
	print("足踏み")
	# ターン終了処理
	var battle_manager = get_tree().get_first_node_in_group("battle_manager")
	if battle_manager:
		battle_manager.end_turn(self)
	else:
		# battle_managerがない場合はturn_managerを使用
		var turn_manager = get_tree().get_first_node_in_group("turn_manager")
		if turn_manager and turn_manager.has_method("process_turn"):
			turn_manager.process_turn()

func open_item_menu():
	"""アイテムメニューを開く"""
	var item_menu = get_tree().get_first_node_in_group("item_menu")
	if not item_menu:
		# ItemMenuノードを探す
		item_menu = get_tree().root.find_child("ItemMenu", true, false)
	if item_menu and item_menu.has_method("show_menu"):
		item_menu.show_menu()

func check_shop_entrance():
	"""店の入口にいるかチェック"""
	var field = get_tree().get_first_node_in_group("field")
	if field and "shop_positions" in field:
		for shop_pos in field.shop_positions:
			if grid_position == shop_pos:
				# 店に入る
				var shop_interior = get_tree().root.find_child("ShopInterior", true, false)
				if shop_interior and shop_interior.has_method("show_shop"):
					# メインフィールドのプレイヤーを非表示
					visible = false
					shop_interior.show_shop()
				break

func show_player():
	"""プレイヤーを表示"""
	visible = true

func start_magic_mode():
	"""魔法モード開始"""
	print("魔法モード開始!")

	# MagicSelectorを取得
	var magic_selector = get_tree().root.find_child("MagicSelector", true, false)
	if not magic_selector:
		# なければ作成
		var field = get_tree().get_first_node_in_group("field")
		if field:
			magic_selector = preload("res://magic_selector.gd").new()
			magic_selector.name = "MagicSelector"
			field.add_child(magic_selector)
			magic_selector.magic_cast.connect(_on_magic_cast)

	if magic_selector:
		magic_selector.start_selection(self, fire_magic)

func _on_magic_cast(target_pos: Vector2i):
	"""魔法発動"""
	fire_magic.cast(self, target_pos)

	# 少し待ってからターン終了(エフェクト表示のため)
	await get_tree().create_timer(0.5).timeout

	# ターン終了
	var turn_manager = get_tree().get_first_node_in_group("turn_manager")
	if turn_manager and turn_manager.has_method("process_turn"):
		turn_manager.process_turn()

func move_to_grid(new_grid_pos: Vector2i):
	# グリッドの範囲チェック(奥行き5マスまで)
	if new_grid_pos.y < 0 or new_grid_pos.y >= 5:
		return

	# 左端は移動不可
	if new_grid_pos.x < 0:
		return

	# 地形判定
	if not can_move_to(new_grid_pos):
		return

	grid_position = new_grid_pos
	target_position = grid_to_pixel(grid_position)
	is_moving = true

	# 店の入口チェック
	check_shop_entrance()

func can_move_to(grid_pos: Vector2i) -> bool:
	# フィールドのGroundLayerから地形チェック
	var field = get_tree().get_first_node_in_group("field")
	if field and field.has_node("GroundLayer"):
		var ground_layer = field.get_node("GroundLayer")
		var cell_source_id = ground_layer.get_cell_source_id(grid_pos)
		# タイルがない場所(-1)は移動不可
		if cell_source_id == -1:
			print("移動不可: ", grid_pos, " タイルなし")
			return false

	# 敵がいるマスは移動不可
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.grid_position == grid_pos:
			print("移動不可: ", grid_pos, " 敵がいる")
			return false

	print("移動可能: ", grid_pos)
	return true

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	# マスの中心に配置 + オフセット
	return Vector2(grid_pos.x * GRID_SIZE + GRID_SIZE / 2.0, grid_pos.y * GRID_SIZE + GRID_SIZE / 2.0) + SPRITE_OFFSET

func attack(target):
	"""攻撃処理"""
	if not target or target.hp <= 0:
		return

	# ダメージ計算: 攻撃力 - 防御力(最低1ダメージ)
	var damage = max(1, attack_power - target.defense)
	target.take_damage(damage)
	print(name, " が ", target.name, " に ", damage, " ダメージ!")

func take_damage(damage: int):
	"""ダメージを受ける"""
	hp -= damage
	if hp <= 0:
		hp = 0
		die()
	print(name, " が ", damage, " ダメージを受けた! (残りHP: ", hp, ")")

func die():
	"""死亡処理"""
	print(name, " は倒れた...")
	# シーンをリロードして最初からやり直し
	get_tree().reload_current_scene()
