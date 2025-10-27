extends Resource
class_name Magic

# 魔法の基本クラス

@export var magic_name: String = ""
@export var description: String = ""
@export var range: int = 3  # 射程
@export var mp_cost: int = 10  # MP消費

func cast(caster, target_pos: Vector2i):
	"""魔法発動(サブクラスでオーバーライド)"""
	pass

func can_cast(caster) -> bool:
	"""使用可能かチェック"""
	return true
