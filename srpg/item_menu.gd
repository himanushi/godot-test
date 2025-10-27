extends CanvasLayer

@onready var panel = $Panel
@onready var item_list = $Panel/VBoxContainer/ItemList
@onready var close_button = $Panel/VBoxContainer/CloseButton

var player = null
var is_open = false

func _ready():
	hide_menu()
	close_button.pressed.connect(_on_close_button_pressed)
	item_list.item_activated.connect(_on_item_activated)

func show_menu():
	"""メニュー表示"""
	player = get_tree().get_first_node_in_group("player")
	if not player or not player.inventory:
		return

	is_open = true
	panel.visible = true
	update_item_list()

func hide_menu():
	"""メニュー非表示"""
	is_open = false
	panel.visible = false

func update_item_list():
	"""アイテムリスト更新"""
	item_list.clear()
	if player and player.inventory:
		var items = player.inventory.get_items()
		for i in range(items.size()):
			var item = items[i]
			item_list.add_item(item.item_name + " - " + item.description)

func _on_item_activated(index: int):
	"""アイテム使用"""
	if player and player.inventory:
		player.inventory.use_item(index, player)
		update_item_list()

		# ターン消費
		var turn_manager = get_tree().get_first_node_in_group("turn_manager")
		if turn_manager and turn_manager.has_method("process_turn"):
			turn_manager.process_turn()

		hide_menu()

func _on_close_button_pressed():
	"""閉じるボタン"""
	hide_menu()

func _input(event):
	if event.is_action_pressed("ui_cancel") and is_open:
		hide_menu()
