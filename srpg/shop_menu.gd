extends CanvasLayer

# 店の販売メニュー

@onready var panel = $Panel
@onready var item_list = $Panel/VBoxContainer/ItemList
@onready var close_button = $Panel/VBoxContainer/CloseButton

var player = null
var is_open = false

# 販売アイテム
var shop_items = []

func _ready():
	hide_menu()
	close_button.pressed.connect(_on_close_button_pressed)
	item_list.item_activated.connect(_on_item_activated)

	# 販売アイテムを設定
	shop_items = [
		AttackPotion.new(),
		AttackPotion.new(),
		AttackPotion.new(),
	]

func show_menu():
	"""メニュー表示"""
	player = get_tree().get_first_node_in_group("player")
	if not player:
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
	for i in range(shop_items.size()):
		var item = shop_items[i]
		item_list.add_item(item.item_name + " - " + item.description)

func _on_item_activated(index: int):
	"""アイテムを貰う"""
	if index >= 0 and index < shop_items.size():
		var item = shop_items[index]
		if player and player.inventory:
			# アイテムを複製して渡す
			var new_item = AttackPotion.new()  # TODO: 動的に生成
			player.inventory.add_item(new_item)
			print("アイテムを入手: ", item.item_name)

func _on_close_button_pressed():
	"""閉じるボタン"""
	hide_menu()

func _input(event):
	if event.is_action_pressed("ui_cancel") and is_open:
		hide_menu()
