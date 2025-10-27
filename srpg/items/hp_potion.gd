extends Item
class_name HpPotion

func _init():
	item_name = "ポーション"
	description = "HPを30回復する"

func use(target):
	if target and "hp" in target and "max_hp" in target:
		var heal_amount = 30
		var old_hp = target.hp
		target.hp = min(target.hp + heal_amount, target.max_hp)
		var actual_heal = target.hp - old_hp
		print(target.name, " のHPが", actual_heal, "回復した! (", target.hp, "/", target.max_hp, ")")
		return true
	return false
