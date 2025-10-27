extends CPUParticles2D

# 炎魔法のパーティクルエフェクト

func _ready():
	# パーティクル設定
	emitting = false
	one_shot = true
	explosiveness = 0.8
	lifetime = 1.0
	amount = 30

	# 見た目
	color = Color(1.0, 0.5, 0.0, 1.0)  # オレンジ
	color_ramp = create_color_gradient()

	# 形状
	emission_shape = EMISSION_SHAPE_SPHERE
	emission_sphere_radius = 10.0

	# 動き
	direction = Vector2(0, -1)
	spread = 45.0
	gravity = Vector2(0, 50)
	initial_velocity_min = 100.0
	initial_velocity_max = 150.0

	# サイズ
	scale_amount_min = 2.0
	scale_amount_max = 4.0
	scale_amount_curve = create_scale_curve()

func create_color_gradient() -> Gradient:
	"""色のグラデーション作成"""
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 0.0, 1.0))  # 黄色
	gradient.set_color(1, Color(1.0, 0.0, 0.0, 0.0))  # 赤→透明
	return gradient

func create_scale_curve() -> Curve:
	"""スケールカーブ作成"""
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1.0))
	curve.add_point(Vector2(1, 0.0))
	return curve

func play_effect():
	"""エフェクト再生"""
	emitting = true
	# 1秒後に自動削除
	await get_tree().create_timer(lifetime + 0.5).timeout
	queue_free()
