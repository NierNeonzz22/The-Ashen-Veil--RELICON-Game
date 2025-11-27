extends Node2D

# Game variables
var current_level = 1
var sequence_notes = []
var current_note_index = 0
var is_player_turn = false
var game_active = true
var is_first_sequence = true

# ADD THIS: Prevent multiple game over calls
var game_ended = false

# References - UPDATED with correct node name
@onready var player = $Tristan_gameplay  # Changed from $Player
@onready var camera = $Tristan_gameplay/Camera2D  # Updated path
@onready var buttons_camera = $ButtonsCamera
@onready var button_container = $ButtonContainer
@export var label_scene: PackedScene

# Timer UI integration
@export var timer_ui_scene: PackedScene  # Assign your TimerUI.tscn here
var timer_ui_instance: Node2D = null
var game_timer: Timer
var time_remaining: float = 0.0
var level_time_limits = {
	1: 30.0,   # INCREASED from 10 to 30 seconds
	2: 55.0,   
	3: 65.0,   
	4: 75.0,   
	5: 85.0,   
	6: 95.0,   
	7: 105.0   
}

# Store original camera offset
var original_camera_offset: Vector2

# Level sequences
var level_data = {
	1: {
		"notes": [5, 1, 3],
		"bpm": 91,
		"description": "D#5, A#4, C#5"
	},
	2: {
		"notes": [3, 7, 2, 0, 8],
		"bpm": 121,
		"description": "C#5, G#4, A#5, REST, G#5"
	},
	3: {
		"notes": [2, 8, 6, 0, 3, 4],
		"bpm": 121,
		"description": "A#5, G#5, F#5, REST, C#5, C#6"
	},
	4: {
		"notes": [4, 0, 3, 0, 2, 8, 4, 0, 3],
		"bpm": 120,
		"description": "C#6, REST, C#5, REST, A#5, G#5, C#6, REST, C#5"
	},
	5: {
		"notes": [5, 1, 2, 0, 8, 0, 3, 7, 8, 0, 6],
		"bpm": 120,
		"description": "D#5, A#4, A#5, REST, G#5, REST, C#5, G#4, G#5, REST, F#5"
	},
	6: {
		"notes": [5, 1, 4, 0, 8, 0.5, 3, 0, 4, 0, 6, 0.5, 3, 0, 2],
		"bpm": 120,
		"description": "D#5, A#4, C#6, REST, G#5, REST, C#5, REST, C#6, REST, F#5, REST, C#5, REST, A#5"
	},
	7: {
		"notes": [5, 1, 3, 0, 2, 0, 8, 6, 3, 0, 4],
		"bpm": 121,
		"description": "D#5, A#4, C#5, REST, A#5, REST, G#5, F#5, C#5, REST, C#6"
	}
}

func _ready():
	# Debug: Check if references are valid
	print("Player reference: ", player)
	print("Camera reference: ", camera)
	print("ButtonsCamera reference: ", buttons_camera)
	
	# Store the camera's original offset from player
	if camera:
		original_camera_offset = camera.position
		print("Original camera offset: ", original_camera_offset)
	
	# Setup game timer
	_setup_game_timer()
	
	connect_buttons()
	start_game()

func _setup_game_timer():
	game_timer = Timer.new()
	add_child(game_timer)
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_game_timeout)

func connect_buttons():
	print("=== CONNECTING BUTTONS ===")
	for i in range(1, 9):
		var button = button_container.get_node("Button" + str(i))
		if button:
			print("Found Button" + str(i) + ": ", button)
			# Check if signal is already connected
			if not button.button_pressed.is_connected(on_button_pressed):
				button.button_pressed.connect(on_button_pressed)
				print("Connected Button" + str(i))
			else:
				print("Button" + str(i) + " already connected")
		else:
			print("❌ Button" + str(i) + " NOT FOUND!")

func start_game():
	current_level = 1
	is_first_sequence = true
	load_level(current_level, false)  # Pass false for is_retry

func load_level(level_num, is_retry: bool = false):
	if not level_num in level_data:
		print("*** ALL LEVELS COMPLETED! ***")
		# TRANSITION TO WIN SCENE
		await get_tree().create_timer(2.0).timeout
		TransitionManager.transition_to_scene("res://scenes/dayonscene.tscn")
		return
		
	var level = level_data[level_num]
	sequence_notes = level["notes"].duplicate()
	current_note_index = 0
	is_player_turn = false
	game_active = true
	game_ended = false
	
	# Only reset timer if it's NOT a retry (i.e., fresh level load)
	if not is_retry:
		time_remaining = level_time_limits.get(level_num, 60.0)
		print("=== LEVEL ", level_num, " ===")
		print("Sequence: ", level["description"])
		print("Time limit: ", time_remaining, " seconds")
	else:
		print("=== RETRY LEVEL ", level_num, " ===")
		print("Time remaining: ", time_remaining, " seconds")
	
	disable_all_buttons()
	demonstrate_sequence(level["bpm"])

func demonstrate_sequence(bpm):
	# Only pan camera for the very first sequence of Level 1
	if is_first_sequence and current_level == 1 and buttons_camera and player and camera:
		await pan_to_buttons()
	
	var base_note_delay = 60.0 / bpm
	
	# Play sequence with rests for proper rhythm
	for i in range(sequence_notes.size()):
		await play_single_sequence_note(i, base_note_delay)
	
	# Only pan back for the very first sequence of Level 1
	if is_first_sequence and current_level == 1 and player and camera:
		await pan_to_player()
		is_first_sequence = false
	
	# Start timer and player turn AFTER camera pans back
	start_player_turn()

func pan_to_buttons():
	print("Panning to buttons...")
	
	if not buttons_camera or not player or not camera:
		print("ERROR: Missing references for camera pan!")
		return
	
	# Calculate the offset needed to center camera on buttons
	var buttons_global_pos = buttons_camera.global_position
	var player_global_pos = player.global_position
	var desired_camera_offset = buttons_global_pos - player_global_pos
	
	print("Player global position: ", player_global_pos)
	print("Buttons global position: ", buttons_global_pos)
	print("Desired camera offset: ", desired_camera_offset)
	
	# Smoothly tween the camera offset to focus on buttons
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "position", desired_camera_offset, 2.0)
	await tween.finished
	
	print("Camera pan to buttons complete")

func pan_to_player():
	print("Panning back to player...")
	
	if not player or not camera:
		print("ERROR: Missing references for camera return!")
		return
	
	# Smoothly tween the camera offset back to original (centered on player)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "position", original_camera_offset, 2.0)
	await tween.finished
	
	print("Camera pan to player complete")
	
	# Spawn label in player's Camera2D after pan is complete
	spawn_label_in_camera()

func spawn_label_in_camera():
	# Make sure we have the camera reference
	if not camera:
		print("ERROR: No camera reference for spawning label!")
		return
	
	# Load your label scene (replace with your actual scene path)
	var label_scene = preload("res://scenes/label_instruction.tscn")
	var label_instance = label_scene.instantiate()
	
	# Add as child of the Camera2D so it stays fixed on screen
	camera.add_child(label_instance)
	
	# Set your custom text if the label has a method to do so
	if label_instance.has_method("set_text"):
		label_instance.set_text("Match the notes being played by the musical rocks within the given time!")
	elif label_instance.has_node("Label") and label_instance.get_node("Label") is Label:
		label_instance.get_node("Label").text = "Match the notes being played by the musical rocks within the given time!"
	
	# Position in bottom right corner of camera view
	# Get the camera's viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	# Position relative to camera (bottom right with some margin)
	label_instance.position = Vector2(viewport_size.x / 2 - 200, viewport_size.y / 2 - 100)
	
	print("Label spawned in Camera2D at bottom right")
	
	# If your scene has custom methods to trigger animations, call them here
	if label_instance.has_method("slide_in"):
		label_instance.slide_in()
	
	# Wait for the label to be on screen, then wait a bit before sliding out
	await get_tree().create_timer(3.0).timeout  # Show for 3 seconds
	
	# Trigger slide out animation
	if label_instance.has_method("slide_out"):
		label_instance.slide_out()
		
		# Wait for slide out animation to complete before removing
		await get_tree().create_timer(1.0).timeout  # Adjust to match your animation duration
	
	# Remove the label after it slides out
	label_instance.queue_free()

func _on_label_slide_in_completed():
	print("Label slide in completed")
	# You could add logic here for when the slide in finishes

func _on_label_slide_out_completed(label_instance):
	print("Label slide out completed")
	# Remove the label after slide out animation finishes
	label_instance.queue_free()

func play_single_sequence_note(index: int, base_note_delay: float):
	var note = sequence_notes[index]
	
	if note == 0:
		await get_tree().create_timer(base_note_delay).timeout
	elif note > 0 and note < 1:
		var fractional_delay = base_note_delay * abs(note)
		await get_tree().create_timer(fractional_delay).timeout
	else:
		var button_number = abs(note)
		highlight_button(button_number)
		await get_tree().create_timer(base_note_delay).timeout

func highlight_button(note_number: int):
	var button = button_container.get_node("Button" + str(note_number))
	if button:
		button.highlight()

func start_player_turn():
	print("🎮 PLAYER TURN STARTED - Buttons should be enabled now!")
	is_player_turn = true
	current_note_index = 0
	skip_initial_rests()
	enable_all_buttons()
	
	# Start the timer and create timer UI
	start_level_timer()

func start_level_timer():
	# Create timer UI
	if timer_ui_scene and not timer_ui_instance:
		timer_ui_instance = timer_ui_scene.instantiate()
		
		# Make the timer a child of the camera so it stays fixed on screen (HUD style)
		if camera:
			camera.add_child(timer_ui_instance)
			# Position relative to camera (screen coordinates)
			# Adjust these values to position it where you want on screen
			timer_ui_instance.position = Vector2(0, -200)  # 200 pixels above center
			print("Timer added as child of camera at fixed screen position")
		else:
			# Fallback if camera not available
			add_child(timer_ui_instance)
			timer_ui_instance.position = Vector2(400, 100)
		
		print("Timer UI created for rhythm game as HUD element")
	
	# Start the game timer
	game_timer.start(time_remaining)
	set_process(true)
	
	# Update timer display immediately
	_update_timer_display()

func _process(delta):
	if game_active and is_player_turn and not game_ended:
		time_remaining -= delta
		_update_timer_display()
		
		if time_remaining <= 0:
			print("⏰ TIME'S UP in _process! Calling game over...")
			game_active = false
			set_process(false)
			# Use call_deferred to ensure game_over runs in the next frame
			call_deferred("game_over")

func _update_timer_display():
	# Update the timer UI if it exists
	if timer_ui_instance and timer_ui_instance.has_method("update_time"):
		timer_ui_instance.update_time(time_remaining)

func skip_initial_rests():
	while current_note_index < sequence_notes.size() and (sequence_notes[current_note_index] == 0 or (sequence_notes[current_note_index] > 0 and sequence_notes[current_note_index] < 1)):
		current_note_index += 1

func on_button_pressed(button_number: int):
	print("🎹 BUTTON PRESSED: Button", button_number, " - is_player_turn:", is_player_turn, " game_active:", game_active)
	
	if not is_player_turn or not game_active:
		print("❌ BUTTON REJECTED - Not player turn or game not active")
		return
		
	print("✅ BUTTON ACCEPTED - Processing input...")
		
	while current_note_index < sequence_notes.size() and (sequence_notes[current_note_index] == 0 or (sequence_notes[current_note_index] > 0 and sequence_notes[current_note_index] < 1)):
		current_note_index += 1
	
	if current_note_index >= sequence_notes.size():
		print("⚠️ Button pressed but sequence already complete?")
		game_over()
		return
	
	var current_note = sequence_notes[current_note_index]
	var actual_note = abs(current_note)
	
	print("You pressed: ", get_note_name(button_number), " | Expected: ", get_note_name(actual_note))
	
	if button_number == actual_note:
		current_note_index += 1
		
		while current_note_index < sequence_notes.size() and (sequence_notes[current_note_index] == 0 or (sequence_notes[current_note_index] > 0 and sequence_notes[current_note_index] < 1)):
			current_note_index += 1
		
		if current_note_index >= sequence_notes.size():
			await handle_win()
		else:
			print("Correct! Continue...")
	else:
	# WRONG BUTTON - REPLAY THE DEMONSTRATION SEQUENCE
		print("❌ Wrong note! Replaying the sequence...")
		is_player_turn = false
		disable_all_buttons()
		await get_tree().create_timer(2.0).timeout  # Changed from 0.5 to 2.0 seconds
		demonstrate_sequence(level_data[current_level]["bpm"])

func get_note_name(button_number: int) -> String:
	var note_names = {
		1: "A#4", 2: "A#5", 3: "C#5", 4: "C#6",
		5: "D#5", 6: "F#5", 7: "G#4", 8: "G#5"
	}
	return note_names.get(button_number, "Unknown")

func handle_win():
	await get_tree().create_timer(0.5).timeout
	win_game()

func win_game():
	print("*** LEVEL ", current_level, " COMPLETE! ***")
	is_player_turn = false
	game_active = false
	set_process(false)
	game_timer.stop()
	disable_all_buttons()
	
	# Clean up timer UI - safe removal even if child of camera
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	await get_tree().create_timer(2.0).timeout
	current_level += 1
	
	# Check if all levels are completed
	if current_level > 7:  # After completing level 7
		print("*** ALL LEVELS COMPLETED! Transitioning to win scene ***")
		# TRANSITION TO WIN SCENE
		TransitionManager.transition_to_scene("res://scenes/dayonscene.tscn")
	else:
		call_deferred("load_level", current_level, false)  # Pass false for is_retry (new level)

func game_over():
	# ADDED: Safety check to prevent multiple calls
	if game_ended:
		print("⚠️ Game over already called, ignoring...")
		return
	
	game_ended = true
	print("💀 GAME OVER function called from timer!")
	
	var expected_index = current_note_index
	while expected_index < sequence_notes.size() and (sequence_notes[expected_index] == 0 or (sequence_notes[expected_index] > 0 and sequence_notes[expected_index] < 1)):
		expected_index += 1
	
	if expected_index < sequence_notes.size():
		var expected_note = get_note_name(abs(sequence_notes[expected_index]))
		print("*** GAME OVER! Expected: ", expected_note, " ***")
	else:
		print("*** GAME OVER! ***")
		
	is_player_turn = false
	game_active = false
	set_process(false)
	game_timer.stop()
	disable_all_buttons()
	
	# Clean up timer UI - safe removal even if child of camera
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	print("💀 Cleanup complete, transitioning in 2 seconds...")
	
	# Use a timer instead of await to be more reliable
	var transition_timer = get_tree().create_timer(2.0)
	await transition_timer.timeout
	
	print("💀 Now transitioning to Dayon lose scene...")
	
	# Direct transition
	if has_node("/root/TransitionManager"):
		print("✅ Using TransitionManager")
		TransitionManager.transition_to_scene("res://scenes/Dayon lose.tscn")
	else:
		print("❌ Using direct scene change")
		get_tree().change_scene_to_file("res://scenes/Dayon lose.tscn")

func _on_game_timeout():
	if game_active and is_player_turn and not game_ended:
		print("⏰ GAME TIMER TIMEOUT! Calling game over...")
		game_active = false
		set_process(false)
		call_deferred("game_over")

func disable_all_buttons():
	print("🔴 DISABLING ALL BUTTONS")
	for i in range(1, 9):
		var button = button_container.get_node("Button" + str(i))
		if button:
			button.set_disabled(true)
			print("Disabled Button" + str(i))

func enable_all_buttons():
	print("🟢 ENABLING ALL BUTTONS")
	for i in range(1, 9):
		var button = button_container.get_node("Button" + str(i))
		if button:
			button.set_disabled(false)
			print("Enabled Button" + str(i))
