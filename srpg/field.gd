extends Node2D

const GRID_SIZE = 64
const GRID_DEPTH = 5  # 奥行き

@onready var grid_highlight = $GridHighlight
@onready var ground_layer = $GroundLayer

func _ready():
	setup_tiles()
	draw_grid()

func setup_tiles():
	# 初期タイルを配置(横20マス分)
	for x in range(20):
		for y in range(GRID_DEPTH):
			ground_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func _draw():
	# グリッド線を描画
	for y in range(GRID_DEPTH + 1):
		var start = Vector2(0, y * GRID_SIZE)
		var end = Vector2(1000, y * GRID_SIZE)  # 横に長く
		draw_line(start, end, Color(1, 1, 1, 0.3), 1.0)

	for x in range(15):  # 画面内に表示されるグリッド数
		var start = Vector2(x * GRID_SIZE, 0)
		var end = Vector2(x * GRID_SIZE, GRID_DEPTH * GRID_SIZE)
		draw_line(start, end, Color(1, 1, 1, 0.3), 1.0)

func draw_grid():
	queue_redraw()
