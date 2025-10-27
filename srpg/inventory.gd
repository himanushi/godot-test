extends Node
class_name Inventory

# インベントリ管理

var items: Array = []

func _ready():
	# 初期アイテムを追加(テスト用)
	add_item(AttackPotion.new())
	add_item(AttackPotion.new())
	add_item(AttackPotion.new())

func add_item(item: Item):
	"""アイテムを追加"""
	items.append(item)
	print("アイテム追加: ", item.item_name)

func remove_item(index: int):
	"""アイテムを削除"""
	if index >= 0 and index < items.size():
		items.remove_at(index)

func use_item(index: int, target):
	"""アイテムを使用"""
	if index >= 0 and index < items.size():
		var item = items[index]
		if item.use(target):
			remove_item(index)
			return true
	return false

func get_items() -> Array:
	"""所持アイテムを取得"""
	return items
