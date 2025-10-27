extends Magic
class_name FireMagic

func _init():
	magic_name = "炎魔法"
	description = "指定したマスに炎を放つ。ダメージ15"
	range = 3
	mp_cost = 10

func cast(caster, target_pos: Vector2i):
	"""炎魔法発動"""
	print("炎魔法発動! 対象: ", target_pos)

	# パーティクルエフェクト生成
	spawn_fire_effect(caster, target_pos)

	# 対象マスにいる敵にダメージ
	var enemies = caster.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.grid_position == target_pos:
			var damage = 15
			enemy.take_damage(damage)
			print(enemy.name, " に炎魔法で ", damage, " ダメージ!")
			return true

	print("対象がいません")
	return false

func spawn_fire_effect(caster, target_pos: Vector2i):
	"""炎エフェクトを生成"""
	const GRID_SIZE = 64

	# パーティクル作成
	var particle = CPUParticles2D.new()

	# 基本設定
	particle.emitting = false
	particle.one_shot = true
	particle.explosiveness = 0.8
	particle.lifetime = 1.0
	particle.amount = 30

	# 色設定
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 0.0, 1.0))  # 黄色
	gradient.add_point(0.5, Color(1.0, 0.5, 0.0, 1.0))  # オレンジ
	gradient.add_point(1.0, Color(1.0, 0.0, 0.0, 0.0))  # 赤→透明
	particle.color_ramp = gradient

	# 形状
	particle.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particle.emission_sphere_radius = 15.0

	# 動き
	particle.direction = Vector2(0, -1)
	particle.spread = 45.0
	particle.gravity = Vector2(0, 50)
	particle.initial_velocity_min = 100.0
	particle.initial_velocity_max = 150.0

	# サイズ
	particle.scale_amount_min = 3.0
	particle.scale_amount_max = 5.0
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0, 1.0))
	scale_curve.add_point(Vector2(1, 0.0))
	particle.scale_amount_curve = scale_curve

	# 位置設定
	var pixel_pos = Vector2(
		target_pos.x * GRID_SIZE + GRID_SIZE / 2.0,
		target_pos.y * GRID_SIZE + GRID_SIZE / 2.0
	)
	particle.position = pixel_pos

	# フィールドに追加
	var field = caster.get_tree().get_first_node_in_group("field")
	if field:
		field.add_child(particle)
		particle.emitting = true

		# 1.5秒後に削除
		await caster.get_tree().create_timer(1.5).timeout
		particle.queue_free()
