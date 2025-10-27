extends CanvasLayer

@onready var hp_label = $Panel/VBoxContainer/HPLabel
@onready var hp_bar = $Panel/VBoxContainer/HPBar
@onready var stats_label = $Panel/VBoxContainer/StatsLabel

var player = null

func _ready():
	# プレイヤーを取得
	player = get_tree().get_first_node_in_group("player")
	if player:
		update_display()

func _process(_delta):
	if player:
		update_display()

func update_display():
	# HP表示
	hp_label.text = "HP: %d / %d" % [player.hp, player.max_hp]

	# HPバー
	hp_bar.value = float(player.hp) / float(player.max_hp) * 100.0

	# ステータス表示
	stats_label.text = "攻撃: %d  防御: %d  速さ: %d" % [player.attack_power, player.defense, player.speed]
