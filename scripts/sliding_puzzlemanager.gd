# PuzzleManager.gd
extends Node2D

# Reference to your existing grid positions
@export var grid_positions: Array[Vector2] = [
	Vector2(64, 64), Vector2(208, 64), Vector2(352, 64),
	Vector2(64, 208), Vector2(208, 208), Vector2(352, 208),
	Vector2(64, 352), Vector2(208, 352), Vector2(352, 352)
]

# Export the puzzle pieces so you can assign them in the editor
@export var puzzle_pieces: Array[Node2D] = []  # Only 8 pieces now!
@export var final_piece: Node2D  # The 9th piece that appears on completion

# Track where each piece CURRENTLY is in the grid (index 0-8)
var piece_positions = []  # piece_positions[piece_id] = current_grid_index
var empty_index = 8  # The empty space is always at grid index 8 initially

@export var debug_draw: bool = false

func _ready():
	# If puzzle_pieces array is empty, try to find them automatically
	if puzzle_pieces.is_empty():
		puzzle_pieces = get_piece_references()
	
	# Initialize piece positions
	piece_positions.resize(8)
	for i in range(8):
		piece_positions[i] = i  # Piece 1 at pos 0, Piece 2 at pos 1, etc.
	
	# Hide the final piece initially
	if final_piece:
		final_piece.visible = false
		final_piece.position = grid_positions[8]  # Position it but keep hidden
	
	setup_puzzle()
	
	if debug_draw:
		queue_redraw()

func get_piece_references() -> Array:
	var pieces = []
	
	# Look for pieces as children of THIS node
	for i in range(8):  # Only 8 pieces!
		var piece_name = "Piece" + str(i + 1)
		var piece = get_node_or_null(piece_name)
		if piece:
			pieces.append(piece)
			print("Found piece: ", piece_name)
		else:
			print("Missing piece: ", piece_name)
			pieces.append(null)
	
	return pieces

func setup_puzzle():
	# Position pieces according to their current grid positions
	for piece_id in range(8):
		if piece_id < puzzle_pieces.size() and puzzle_pieces[piece_id]:
			var grid_index = piece_positions[piece_id]
			puzzle_pieces[piece_id].position = grid_positions[grid_index]
			
			# Connect input if using Area2D
			if puzzle_pieces[piece_id] is Area2D:
				if !puzzle_pieces[piece_id].input_event.is_connected(_on_piece_input):
					puzzle_pieces[piece_id].input_event.connect(_on_piece_input.bind(piece_id))

func _on_piece_input(viewport, event, shape_idx, piece_id):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_move_piece(piece_id)

func try_move_piece(piece_id):
	var piece_grid_index = piece_positions[piece_id]
	
	print("Trying to move piece ", piece_id, " from grid position ", piece_grid_index, " | Empty at: ", empty_index)
	
	# SIMPLE ADJACENCY CHECK - just check the four possible directions
	var can_move = false
	
	# Convert grid indices to 2D coordinates
	var piece_pos = Vector2i(piece_grid_index % 3, piece_grid_index / 3)
	var empty_pos = Vector2i(empty_index % 3, empty_index / 3)
	
	# Check all four possible adjacent positions
	if (piece_pos.x == empty_pos.x and abs(piece_pos.y - empty_pos.y) == 1) or \
	   (piece_pos.y == empty_pos.y and abs(piece_pos.x - empty_pos.x) == 1):
		can_move = true
	
	if can_move:
		print("VALID MOVE - Moving piece ", piece_id, " to empty space ", empty_index)
		# Move the piece to the empty space
		move_piece_to_empty(piece_id, piece_grid_index, empty_index)
	else:
		print("INVALID MOVE - Not adjacent")
		print("Piece at grid: ", piece_pos, " Empty at grid: ", empty_pos)

func move_piece_to_empty(piece_id: int, from_index: int, to_index: int):
	if piece_id >= puzzle_pieces.size() or not puzzle_pieces[piece_id]:
		print("ERROR: Invalid piece ID: ", piece_id)
		return
	
	print("Moving piece ", piece_id, " from grid ", from_index, " to grid ", to_index)
	
	# Update piece position tracking
	piece_positions[piece_id] = to_index
	empty_index = from_index  # The empty space moves to where the piece was
	
	print("Piece ", piece_id, " now at grid: ", to_index)
	print("Empty space now at grid: ", empty_index)
	
	# Move the piece visually to the empty position
	var target_pos = grid_positions[to_index]
	
	# Animate the moving piece
	var tween = create_tween()
	tween.tween_property(puzzle_pieces[piece_id], "position", target_pos, 0.3)
	
	if check_win():
		on_puzzle_solved()
	
func check_win() -> bool:
	# Check if each piece is in its correct final position
	# Piece 1 should be at grid 0, Piece 2 at grid 1, ..., Piece 8 at grid 7
	for piece_id in range(8):
		if piece_positions[piece_id] != piece_id:
			return false
	# Empty space should be at position 8 (bottom-right)
	return empty_index == 8

func on_puzzle_solved():
	print("Puzzle Solved! Revealing final piece!")
	
	# Reveal the final piece with a nice animation
	if final_piece:
		final_piece.visible = true
		final_piece.position = grid_positions[8]  # Ensure it's at the correct position
		
		# Optional: Add a pop-in animation
		var tween = create_tween()
		final_piece.scale = Vector2(0, 0)  # Start small
		tween.tween_property(final_piece, "scale", Vector2(1, 1), 0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		# Optional: Play a sound, show particles, etc.
	else:
		print("ERROR: Final piece not assigned!")

# Shuffle using your existing grid
func shuffle_puzzle():
	# Reset to solved state first
	for i in range(8):
		piece_positions[i] = i
	empty_index = 8
	update_piece_positions()
	
	# Then shuffle with valid moves
	for i in range(100):
		var possible_moves = get_possible_moves_for_shuffle()
		if possible_moves.size() > 0:
			var random_piece_id = possible_moves[randi() % possible_moves.size()]
			var piece_grid_index = piece_positions[random_piece_id]
			# Force the move without animation for shuffling
			piece_positions[random_piece_id] = empty_index
			empty_index = piece_grid_index
	
	# Update visual positions after shuffling
	update_piece_positions()

func get_possible_moves_for_shuffle() -> Array:
	var moves = []  # This will contain piece IDs that can move
	
	var empty_grid_pos = Vector2i(empty_index % 3, empty_index / 3)
	var directions = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	
	# Check all four directions around the empty space
	for dir in directions:
		var neighbor_pos = empty_grid_pos + dir
		if neighbor_pos.x >= 0 and neighbor_pos.x < 3 and neighbor_pos.y >= 0 and neighbor_pos.y < 3:
			var neighbor_index = neighbor_pos.y * 3 + neighbor_pos.x
			
			# Find which piece (if any) is at this neighbor position
			for piece_id in range(8):
				if piece_positions[piece_id] == neighbor_index:
					moves.append(piece_id)
					break
	
	return moves

func update_piece_positions():
	# Update all piece positions based on current piece_positions
	for piece_id in range(8):
		if piece_id < puzzle_pieces.size() and puzzle_pieces[piece_id]:
			var grid_index = piece_positions[piece_id]
			puzzle_pieces[piece_id].position = grid_positions[grid_index]

# Optional: Debug drawing to visualize grid positions
func _draw():
	if debug_draw:
		for i in range(grid_positions.size()):
			var pos = grid_positions[i]
			# Draw small red squares at grid positions
			draw_rect(Rect2(pos - Vector2(5, 5), Vector2(10, 10)), Color.RED)
			# Draw position numbers
			var font = ThemeDB.fallback_font
			var font_size = ThemeDB.fallback_font_size
			draw_string(font, pos + Vector2(15, 5), str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
