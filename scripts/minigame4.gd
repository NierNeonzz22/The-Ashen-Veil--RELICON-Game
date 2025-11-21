extends Node2D

const TILE_SIZE = 128
const COLS = 3
const PADDING = 16

@onready var grid := $Grid
var grid_state = []  # 2D array, null = empty

func _ready():
	layout_tiles()
	initialize_grid_state()


func layout_tiles():
	var cell_size = TILE_SIZE + PADDING
	for i in range(8):
		var tile = grid.get_node("Tile_%d" % i) as Area2D
		var sprite = tile.get_node("Tile_%d" % i) as Sprite2D  # get child sprite
		var row = int(i / COLS)
		var col = i % COLS
		tile.position = Vector2(col * cell_size + PADDING / 2, row * cell_size + PADDING / 2)
		sprite.centered = false  # set on the Sprite2D, not Area2D



func initialize_grid_state():
	grid_state.resize(COLS)
	for row in range(COLS):
		grid_state[row] = []
		for col in range(COLS):
			var found_tile: Sprite2D = null
			for i in range(8):
				var t = grid.get_node("Tile_%d" % i) as Sprite2D
				if int(i / COLS) == row and i % COLS == col:
					found_tile = t
					break
			grid_state[row].append(found_tile)
	# bottom-right empty
	grid_state[COLS - 1][COLS - 1] = null


# On Tile_X (Area2D) script:
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_parent().try_move_tile(self)



func find_tile(tile: Sprite2D) -> Vector2:
	for row in range(COLS):
		for col in range(COLS):
			if grid_state[row][col] == tile:
				return Vector2(row, col)
	return Vector2(-1, -1)


func find_empty() -> Vector2:
	for row in range(COLS):
		for col in range(COLS):
			if grid_state[row][col] == null:
				return Vector2(row, col)
	return Vector2(-1, -1)


func can_move(tile: Sprite2D) -> bool:
	var pos = find_tile(tile)
	var empty_pos = find_empty()
	if pos.x < 0:
		return false
	var row_diff = abs(pos.x - empty_pos.x)
	var col_diff = abs(pos.y - empty_pos.y)
	return (row_diff == 1 and col_diff == 0) or (row_diff == 0 and col_diff == 1)


func try_move_tile(tile: Sprite2D):
	if not can_move(tile):
		return
	var pos = find_tile(tile)
	var empty_pos = find_empty()
	# swap in grid state
	grid_state[empty_pos.x][empty_pos.y] = tile
	grid_state[pos.x][pos.y] = null
	# move tile instantly
	var cell_size = TILE_SIZE + PADDING
	tile.position = Vector2(empty_pos.y * cell_size + PADDING / 2,
							empty_pos.x * cell_size + PADDING / 2)
