extends Resource
class_name Item

# アイテムの基本クラス

@export var item_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""

func use(target):
	"""アイテム使用時の処理(サブクラスでオーバーライド)"""
	pass

func can_use() -> bool:
	"""使用可能かチェック"""
	return true
