extends Node

# スプライトシートを読み込んで背景を透明化するヘルパー

const SpriteTransparency = preload("res://utils/sprite_transparency.gd")

# 背景色の定義(茶色っぽい色)
const DEFAULT_BG_COLOR = Color(0.545, 0.42, 0.29, 1.0)
const THRESHOLD = 0.15  # 許容誤差

static func load_sprite_with_transparency(path: String, bg_color: Color = DEFAULT_BG_COLOR) -> ImageTexture:
	"""スプライトを読み込んで背景を透明化"""

	# 元画像を読み込み
	var texture = load(path) as Texture2D
	if not texture:
		push_error("テクスチャを読み込めませんでした: " + path)
		return null

	# 背景を透明化
	return SpriteTransparency.make_color_transparent(texture, bg_color, THRESHOLD)

static func apply_transparency_to_sprite_frames(sprite_frames: SpriteFrames, animation_name: String = "default", bg_color: Color = DEFAULT_BG_COLOR):
	"""既存のSpriteFramesの全フレームに透明化を適用"""

	if not sprite_frames.has_animation(animation_name):
		push_error("アニメーションが見つかりません: " + animation_name)
		return

	var frame_count = sprite_frames.get_frame_count(animation_name)

	for i in range(frame_count):
		var original_texture = sprite_frames.get_frame_texture(animation_name, i)
		if original_texture:
			var transparent_texture = SpriteTransparency.make_color_transparent(original_texture, bg_color, THRESHOLD)
			if transparent_texture:
				sprite_frames.set_frame(animation_name, i, transparent_texture)
				print("フレーム ", i, " を透明化しました")
