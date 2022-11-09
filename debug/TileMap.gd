extends TileMap

var grid_size: Vector2 = Vector2(150,150)
var tile_size = cell_size

func _ready():
	position = (position - grid_size/2) * cell_size

func _draw():
	var LINE_COLOR = Color(0.2, 1.0, 0.7, 0.2)
	var LINE_WIDTH = 5
	var window_size = OS.get_window_size()

	for x in range(grid_size.x + 1):
		var col_pos = x * tile_size.x
		var limit = grid_size.y * tile_size.y
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, limit), LINE_COLOR, LINE_WIDTH)
	for y in range(grid_size.y + 1):
		var row_pos = y * tile_size.y
		var limit = grid_size.x * tile_size.x
		draw_line(Vector2(0, row_pos), Vector2(limit, row_pos), LINE_COLOR, LINE_WIDTH)
