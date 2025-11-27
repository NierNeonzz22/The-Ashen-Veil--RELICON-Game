# PuzzleManager.gd
extends Node2D

# Reference to your existing grid positions
@export var grid_positions: Array[Vector2] = [
	Vector2(64, 64), Vector2(208, 64), Vector2(354, 64),
	Vector2(64, 208), Vector2(208, 208), Vector2(354, 208),
	Vector2(64, 354), Vector2(208, 354), Vector2(354, 354)
]

# Export the puzzle pieces so you can assign them in the editor
@export var puzzle_pieces: Array[Node2D] = []  # Only 8 movable pieces! (all except center)
@export var final_piece: Node2D  # The center piece that appears on completion
@export var complete_image: Sprite2D  # The full image that appears over the entire grid
@export var victory_gem: PackedScene  # Assign your Gem_2.tscn here

# Timer
@export var timer_duration: float = 60.0  # 60 second timer

#Variable for timer
@export var timer_ui_scene: PackedScene  # Assign your TimerUI.tscn here
@export var instruction_label_scene: PackedScene  # Assign your Label_instruction.tscn in inspector
var timer_ui_instance: Node2D
var instruction_instance: Node2D = null

# WINNING STATE: Pieces 1-4,6-9 in positions around center, FinalPiece (center) at position 4
var piece_positions = []  # piece_positions[piece_id] = current_grid_index
var empty_index = 4  # FinalPiece (center) starts as the empty space
var game_won = false
var game_lost = false
var gem_instance: Area2D = null
var timer: Timer
var time_remaining: float = 0.0

@export var test_mode: bool = true  # Set to true for testing, false for normal game

func _ready():
	print("=== PUZZLE MANAGER STARTING ===")
	
	# Fix: Ensure we only use 8 pieces (all except center)
	if puzzle_pieces.size() > 8:
		print("Warning: puzzle_pieces has ", puzzle_pieces.size(), " elements. Using only first 8.")
		puzzle_pieces.resize(8)
	
	# Setup FinalPiece - make sure it's invisible and non-interactive
	if final_piece:
		final_piece.visible = false
		if final_piece is Area2D:
			final_piece.monitoring = false
			final_piece.monitorable = false
	else:
		print("Error: Final piece (center) not assigned!")
	
	# Setup complete image at screen position
	if complete_image:
		complete_image.visible = false
		complete_image.global_position = Vector2(566, 347)
	
	# Setup timer
	setup_timer()
	
	# Initialize puzzle state
	if test_mode:
		initialize_test_puzzle()  # One move from completion
	else:
		initialize_solvable_puzzle()  # Normal shuffled puzzle
	
	# Start puzzle gameplay immediately
	start_puzzle_gameplay()

func setup_timer():
	timer = Timer.new()
	timer.wait_time = 1.0  # Update every second
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func start_puzzle_gameplay():
	print("🎮 PUZZLE GAMEPLAY STARTING")
	print("Timer: ", timer_duration, " seconds")
	
	# Reset game states
	game_won = false
	game_lost = false
	
	# Create timer UI if scene is assigned
	if timer_ui_scene:
		timer_ui_instance = timer_ui_scene.instantiate()
		add_child(timer_ui_instance)
		print("Timer UI created with slide-down animation")
	
	# Show instructions
	show_instructions()
	
	# Setup puzzle connections
	setup_puzzle()
	
	# Start timer
	time_remaining = timer_duration
	timer.start()
	
	# Update timer display
	update_timer_display()
	
	print("Puzzle ready! Pieces should be movable now.")


###############################
# INSTRUCTION SYSTEM
###############################
func show_instructions():
	if instruction_label_scene:
		# Create instruction label instance
		instruction_instance = instruction_label_scene.instantiate()
		add_child(instruction_instance)
		print("Instruction label created")
		
		# Set the instruction text
		if instruction_instance.has_method("set_instruction_text"):
			instruction_instance.set_instruction_text("Click pieces next to the empty space to move.\nSolve the puzzle!")
		
		# Set display duration (show for 10 seconds)
		if instruction_instance.has_method("set_display_time"):
			instruction_instance.set_display_time(10.0)
		
		# Play slide in animation
		if instruction_instance.has_method("show_instructions"):
			instruction_instance.show_instructions()
		elif instruction_instance.has_node("AnimationPlayer"):
			var anim_player = instruction_instance.get_node("AnimationPlayer")
			if anim_player.has_animation("slide_left"):
				anim_player.play("slide_left")


func _on_timer_timeout():
	if game_won or game_lost:
		return
	
	time_remaining -= 1.0
	update_timer_display()
	
	if time_remaining <= 0:
		on_puzzle_lost()

func update_timer_display():
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	var time_text = "%02d:%02d" % [minutes, seconds]
	
	# Update the timer UI if it exists
	if timer_ui_instance and timer_ui_instance.has_method("update_time"):
		timer_ui_instance.update_time(time_remaining)
	
	print("Time remaining: ", time_text)

func on_puzzle_lost():
	game_lost = true
	timer.stop()
	print("⏰ TIME'S UP! Puzzle failed.")
	
	# Remove timer UI when puzzle is lost
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	# Transition to lose scene
	transition_to_lose_scene()

func transition_to_lose_scene():
	print("💀 PUZZLE FAILED! Transitioning to niuala lose scene...")
	TransitionManager.transition_to_scene("res://scenes/niuala lose.tscn")

func initialize_test_puzzle():
	# TEST MODE: Puzzle is ONE MOVE away from completion
	# | Piece1 | Piece2 | Piece3 |
	# | Piece4 | Piece5 | Piece6 | 
	# | Piece7 | EMPTY  | Piece8 |
	
	piece_positions = [0, 1, 2, 3, 4, 5, 6, 8]  # Piece8 at position 8
	empty_index = 7  # Empty space at bottom-middle
	
	print("TEST MODE: Move Piece8 LEFT into the empty space to win!")
	update_piece_positions()

func initialize_solvable_puzzle():
	# Start with solved state - all pieces around center
	piece_positions = [0, 1, 2, 3, 5, 6, 7, 8]  # All pieces around center (position 4 empty)
	empty_index = 4  # Center position is empty
	
	# Create a solvable shuffle by making many valid moves
	var shuffle_moves = 50  # Number of random moves to shuffle
	var directions = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	
	for i in range(shuffle_moves):
		var possible_moves = []
		var empty_pos = Vector2i(empty_index % 3, empty_index / 3)
		
		# Find all possible moves around empty space
		for dir in directions:
			var neighbor_pos = empty_pos + dir
			if neighbor_pos.x >= 0 and neighbor_pos.x < 3 and neighbor_pos.y >= 0 and neighbor_pos.y < 3:
				var neighbor_index = neighbor_pos.y * 3 + neighbor_pos.x
				var piece_id = find_piece_at_grid_index(neighbor_index)
				if piece_id != -1:
					possible_moves.append(piece_id)
		
		# Make a random valid move
		if possible_moves.size() > 0:
			var random_piece = possible_moves[randi() % possible_moves.size()]
			var piece_grid_index = piece_positions[random_piece]
			
			# Swap piece with empty space
			piece_positions[random_piece] = empty_index
			empty_index = piece_grid_index
	
	print("Puzzle shuffled! Good luck!")
	update_piece_positions()

func find_piece_at_grid_index(grid_index: int) -> int:
	for piece_id in range(8):
		if piece_positions[piece_id] == grid_index:
			return piece_id
	return -1

func setup_puzzle():
	# Connect input events for all pieces
	for piece_id in range(8):
		if piece_id < puzzle_pieces.size() and puzzle_pieces[piece_id]:
			if puzzle_pieces[piece_id] is Area2D:
				if !puzzle_pieces[piece_id].input_event.is_connected(_on_piece_input):
					puzzle_pieces[piece_id].input_event.connect(_on_piece_input.bind(piece_id))

func _on_piece_input(viewport, event, shape_idx, piece_id):
	if game_won or game_lost:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_move_piece(piece_id)

func try_move_piece(piece_id):
	var piece_grid_index = piece_positions[piece_id]
	
	# Check if the clicked piece is adjacent to the empty space (center)
	var can_move = false
	
	# Convert grid indices to 2D coordinates
	var piece_pos = Vector2i(piece_grid_index % 3, piece_grid_index / 3)
	var empty_pos = Vector2i(empty_index % 3, empty_index / 3)
	
	# Check all four possible adjacent positions
	if (piece_pos.x == empty_pos.x and abs(piece_pos.y - empty_pos.y) == 1) or \
	   (piece_pos.y == empty_pos.y and abs(piece_pos.x - empty_pos.x) == 1):
		can_move = true
	
	if can_move:
		# Move the piece to the empty space
		move_piece_to_empty(piece_id, piece_grid_index, empty_index)
	
func move_piece_to_empty(piece_id: int, from_index: int, to_index: int):
	if piece_id >= puzzle_pieces.size() or not puzzle_pieces[piece_id]:
		return
	
	# Update piece position tracking
	piece_positions[piece_id] = to_index
	empty_index = from_index  # The empty space moves to where the piece was
	
	# Move the piece visually to the empty position
	var target_pos = grid_positions[to_index]
	
	# Animate the moving piece
	var tween = create_tween()
	tween.tween_property(puzzle_pieces[piece_id], "position", target_pos, 0.3)
	
	if check_win():
		on_puzzle_solved()
	
func check_win() -> bool:
	# Check WINNING PATTERN:
	# All 8 pieces in positions around center (0,1,2,3,5,6,7,8)
	# FinalPiece (center) at position 4
	var winning_positions = [0, 1, 2, 3, 5, 6, 7, 8]
	for i in range(8):
		if piece_positions[i] != winning_positions[i]:
			return false
	return empty_index == 4

func on_puzzle_solved():
	game_won = true
	timer.stop()
	print("🎉 PUZZLE SOLVED! Time: ", timer_duration - time_remaining, " seconds")
	
	# Remove timer UI when puzzle is solved
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	# START VICTORY SEQUENCE IMMEDIATELY
	start_victory_sequence()

func start_victory_sequence():
	print("=== STARTING VICTORY SEQUENCE ===")
	# Step 1: Reveal the center piece with fade-in
	reveal_final_piece()

func reveal_final_piece():
	print("Revealing final piece immediately...")
	if final_piece:
		# Position and show the center piece IMMEDIATELY
		final_piece.position = grid_positions[empty_index]
		final_piece.visible = true
		
		# Fade in from transparent
		final_piece.modulate = Color(1, 1, 1, 0)
		var tween_fade = create_tween()
		tween_fade.tween_property(final_piece, "modulate", Color(1, 1, 1, 1), 1.0)\
			.set_ease(Tween.EASE_IN_OUT)
		
		await tween_fade.finished
		await get_tree().create_timer(0.5).timeout
	
	# Step 2: Play gem animation
	play_gem_animation()

func play_gem_animation():
	print("Playing gem animation...")
	if victory_gem:
		print("Spawning and playing gem animation!")
		
		# Instantiate the gem scene
		gem_instance = victory_gem.instantiate()
		add_child(gem_instance)
		
		# Position the gem at your specified coordinates
		gem_instance.global_position = Vector2(899, 352)
		
		# Play the animation - just get the AnimationPlayer and play without specifying name
		var anim_player = gem_instance.get_node_or_null("AnimationPlayer")
		if anim_player:
			# Get the first animation (usually the default one)
			if anim_player.get_animation_list().size() > 0:
				var animation_name = anim_player.get_animation_list()[0]
				print("Playing gem animation: ", animation_name)
				anim_player.play(animation_name)
				await anim_player.animation_finished
			else:
				print("No animations found in AnimationPlayer")
		else:
			print("No AnimationPlayer found on gem instance")
		
		await get_tree().create_timer(0.5).timeout
	
	# Step 3: Show the complete image
	show_complete_image()

func show_complete_image():
	print("Showing complete image...")
	if complete_image:
		complete_image.visible = true
		complete_image.global_position = Vector2(566, 347)
		complete_image.modulate = Color(1, 1, 1, 0)
		
		var tween = create_tween()
		tween.tween_property(complete_image, "modulate", Color(1, 1, 1, 1), 1.5)\
			.set_ease(Tween.EASE_IN_OUT)
		
		await tween.finished
		
		# Step 4: AFTER victory sequence is complete, transition to niuala scene
		transition_to_niuala_scene()

func transition_to_niuala_scene():
	print("🏆 PUZZLE COMPLETED! Transitioning to scene 3 niuala...")
	
	# Wait a moment to let the player see the completed puzzle
	await get_tree().create_timer(2.0).timeout
	
	# Use TransitionManager to go to the niuala scene
	TransitionManager.transition_to_scene("res://scenes/scene 3 niuala win.tscn")

func update_piece_positions():
	# Update all piece positions based on current piece_positions
	for piece_id in range(8):
		if piece_id < puzzle_pieces.size() and puzzle_pieces[piece_id]:
			var grid_index = piece_positions[piece_id]
			puzzle_pieces[piece_id].position = grid_positions[grid_index]
