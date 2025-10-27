extends Item
class_name AttackPotion

func _init():
	item_name = "攻撃アップのくすり"
	description = "攻撃力が5上がる"

func use(target):
	if target and "attack_power" in target:
		target.attack_power += 5
		print(target.name, " の攻撃力が5上がった! (", target.attack_power, ")")
		return true
	return false
