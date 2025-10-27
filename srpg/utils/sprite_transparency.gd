extends Node

# スプライトの背景色を透明化するユーティリティ

static func make_color_transparent(texture: Texture2D, target_color: Color, threshold: float = 0.1) -> ImageTexture:
	"""指定した色を透明にした新しいテクスチャを返す"""

	# テクスチャから画像を取得
	var image = texture.get_image()
	if not image:
		push_error("画像を取得できませんでした")
		return null

	# 編集可能な形式に変換
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)

	# ピクセル単位で処理
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel_color = image.get_pixel(x, y)

			# 背景色との距離を計算
			var diff = color_distance(pixel_color, target_color)

			# 閾値以下なら透明に
			if diff < threshold:
				pixel_color.a = 0.0
				image.set_pixel(x, y, pixel_color)

	# 新しいテクスチャを作成
	return ImageTexture.create_from_image(image)

static func color_distance(c1: Color, c2: Color) -> float:
	"""2つの色の距離を計算"""
	var dr = c1.r - c2.r
	var dg = c1.g - c2.g
	var db = c1.b - c2.b
	return sqrt(dr*dr + dg*dg + db*db)

static func auto_detect_background_color(texture: Texture2D) -> Color:
	"""画像の四隅から背景色を自動検出"""
	var image = texture.get_image()
	if not image:
		return Color.WHITE

	# 四隅の色を取得
	var corners = [
		image.get_pixel(0, 0),
		image.get_pixel(image.get_width() - 1, 0),
		image.get_pixel(0, image.get_height() - 1),
		image.get_pixel(image.get_width() - 1, image.get_height() - 1)
	]

	# 最も多い色を背景色とする(簡易版)
	return corners[0]
