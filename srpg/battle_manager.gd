extends Node

# バトル管理クラス - スピードベースの行動順管理

signal battle_started
signal turn_started(character)
signal turn_ended(character)
signal battle_ended

const ACTION_GAUGE_THRESHOLD = 100  # 行動に必要なゲージ量

var all_characters = []  # 全キャラクター(プレイヤー + 敵)
var action_gauges = {}  # 各キャラのアクションゲージ {character: gauge_value}
var is_battle_active = false

func _ready():
	add_to_group("battle_manager")

func start_battle():
	"""バトル開始"""
	is_battle_active = true

	# 全キャラクターを収集
	all_characters.clear()
	action_gauges.clear()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		all_characters.append(player)
		action_gauges[player] = 0

	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		all_characters.append(enemy)
		action_gauges[enemy] = 0

	emit_signal("battle_started")
	print("バトル開始!")

	# 最初のターンを処理
	process_next_turn()

func process_next_turn():
	"""次の行動キャラを決定して実行"""
	if not is_battle_active:
		return

	# 全キャラのゲージをスピードに応じて増加
	var max_gauge = 0
	var next_character = null

	# まず全員のゲージを増やす
	for character in all_characters:
		if character.hp > 0:  # 生存しているキャラのみ
			action_gauges[character] += character.speed

			# 最大ゲージを持つキャラを探す
			if action_gauges[character] >= ACTION_GAUGE_THRESHOLD:
				if action_gauges[character] > max_gauge:
					max_gauge = action_gauges[character]
					next_character = character

	# 行動可能なキャラがいる場合
	if next_character:
		# ゲージを消費
		action_gauges[next_character] -= ACTION_GAUGE_THRESHOLD

		emit_signal("turn_started", next_character)
		print(next_character.name, " のターン (Speed:", next_character.speed, ")")

		# キャラのターン処理を実行
		if next_character.is_in_group("player"):
			execute_player_turn(next_character)
		else:
			execute_enemy_turn(next_character)
	else:
		# 誰も行動できない場合、全員にゲージを加算して再試行
		process_next_turn()

func execute_player_turn(player):
	"""プレイヤーのターン実行"""
	# プレイヤーが移動するまで待つ(既存の入力システムを使用)
	# 移動完了後にend_turn()を呼ぶ必要がある
	print("プレイヤーのターン: 移動してください")

func execute_enemy_turn(enemy):
	"""敵のターン実行"""
	if enemy.has_method("take_turn"):
		enemy.take_turn()

	# 敵のターン終了
	await get_tree().create_timer(0.3).timeout  # アニメーション待ち
	end_turn(enemy)

func end_turn(character):
	"""ターン終了処理"""
	emit_signal("turn_ended", character)

	# バトル終了判定
	if check_battle_end():
		end_battle()
		return

	# 次のターンへ
	process_next_turn()

func check_battle_end() -> bool:
	"""バトル終了判定"""
	var player_alive = false
	var enemy_alive = false

	for character in all_characters:
		if character.hp > 0:
			if character.is_in_group("player"):
				player_alive = true
			else:
				enemy_alive = true

	return not player_alive or not enemy_alive

func end_battle():
	"""バトル終了"""
	is_battle_active = false
	emit_signal("battle_ended")
	print("バトル終了!")
