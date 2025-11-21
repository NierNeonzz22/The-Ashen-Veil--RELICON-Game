extends Node2D

# Game variables
var current_level = 1
var sequence_notes = []
var current_note_index = 0
var is_player_turn = false
var game_active = true

# Level sequences with rests for rhythm, but player only clicks notes
var level_data = {
	1: {
		"notes": [5, 1, 3],  # D#5, A#4, C#5
		"bpm": 91,
		"description": "D#5, A#4, C#5"
	},
	2: {
		"notes": [3, 7, 2, 0, 8],  # C#5, G#4, A#5, REST, G#5
		"bpm": 121,
		"description": "C#5, G#4, A#5, REST, G#5"
	},
	3: {
		"notes": [2, 8, 6, 0, 3, 4],  # A#5, G#5, F#5, REST, C#5, C#6
		"bpm": 121,
		"description": "A#5, G#5, F#5, REST, C#5, C#6"
	},
	4: {
		"notes": [4, 0, 3, 0, 2, 8, 4, 0, 3],  # C#6, REST, C#5, REST, A#5, G#5, C#6, REST, C#5
		"bpm": 120,
		"description": "C#6, REST, C#5, REST, A#5, G#5, C#6, REST, C#5"
	},
	5: {
		"notes": [5, 1, 2, 0, 8, 0, 3, 7, 8, 0, 6],  # D#5, A#4, A#5, REST, G#5, REST, C#5, G#4, G#5, REST, F#5
		"bpm": 120,
		"description": "D#5, A#4, A#5, REST, G#5, REST, C#5, G#4, G#5, REST, F#5"
	},
	6: {
		"notes": [5, 1, 4, 0, 8, 0.5, 3, 0, 4, 0, 6, 0.5, 3, 0, 2],  # With rests for rhythm
		"bpm": 120,
		"description": "D#5, A#4, C#6, REST, G#5, REST, C#5, REST, C#6, REST, F#5, REST, C#5, REST, A#5"
	},
	7: {
		"notes": [5, 1, 3, 0, 2, 0, 8, 6, 3, 0, 4],  # D#5, A#4, C#5, REST, A#5, REST, G#5, F#5, C#5, REST, C#6
		"bpm": 121,
		"description": "D#5, A#4, C#5, REST, A#5, REST, G#5, F#5, C#5, REST, C#6"
	}
}

# References
@onready var button_container = $ButtonContainer

func _ready():
	connect_buttons()
	start_game()

func connect_buttons():
	for i in range(1, 9):
		var button = button_container.get_node("Button" + str(i))
		if button:
			button.button_pressed.connect(on_button_pressed)

func start_game():
	current_level = 1
	load_level(current_level)

func load_level(level_num):
	if not level_num in level_data:
		print("*** ALL LEVELS COMPLETED! ***")
		return
		
	var level = level_data[level_num]
	sequence_notes = level["notes"].duplicate()
	current_note_index = 0
	is_player_turn = false
	game_active = true
	
	print("=== LEVEL ", level_num, " ===")
	print("Sequence: ", level["description"])
	
	disable_all_buttons()
	demonstrate_sequence(level["bpm"])

func demonstrate_sequence(bpm):
	var base_note_delay = 60.0 / bpm
	
	# Play sequence with rests for proper rhythm
	for i in range(sequence_notes.size()):
		await play_single_sequence_note(i, base_note_delay)
	
	start_player_turn()

func play_single_sequence_note(index: int, base_note_delay: float):
	var note = sequence_notes[index]
	
	if note == 0:  # REST note - just wait, no highlight
		await get_tree().create_timer(base_note_delay).timeout
	elif note > 0 and note < 1:  # Fractional rest
		var fractional_delay = base_note_delay * abs(note)
		await get_tree().create_timer(fractional_delay).timeout
	else:  # Regular note (1-8) - highlight and play sound
		var button_number = abs(note)  # Handle negative values if any
		highlight_button(button_number)
		await get_tree().create_timer(base_note_delay).timeout

func highlight_button(note_number: int):
	var button = button_container.get_node("Button" + str(note_number))
	if button:
		button.highlight()

func start_player_turn():
	print("Your turn! Repeat the sequence (ignore timing, just get the order right)")
	is_player_turn = true
	current_note_index = 0
	
	# Skip any rests at the start of the sequence
	skip_initial_rests()
	
	enable_all_buttons()

func skip_initial_rests():
	# Skip over any rests at the beginning of the sequence
	while current_note_index < sequence_notes.size() and (sequence_notes[current_note_index] == 0 or (sequence_notes[current_note_index] > 0 and sequence_notes[current_note_index] < 1)):
		current_note_index += 1

func on_button_pressed(button_number: int):
	if not is_player_turn or not game_active:
		return
		
	# Skip any rests and find the next actual note
	while current_note_index < sequence_notes.size() and (sequence_notes[current_note_index] == 0 or (sequence_notes[current_note_index] > 0 and sequence_notes[current_note_index] < 1)):
		current_note_index += 1
	
	# Check if we've reached the end
	if current_note_index >= sequence_notes.size():
		game_over()
		return
	
	var current_note = sequence_notes[current_note_index]
	var actual_note = abs(current_note)  # Handle negative values
	
	print("You pressed: ", get_note_name(button_number), " | Expected: ", get_note_name(actual_note))
	
	# Check if this is the correct next note in sequence
	if button_number == actual_note:
		# Correct! Move to next note
		current_note_index += 1
		
		# Skip any consecutive rests
		while current_note_index < sequence_notes.size() and (sequence_notes[current_note_index] == 0 or (sequence_notes[current_note_index] > 0 and sequence_notes[current_note_index] < 1)):
			current_note_index += 1
		
		# Check if sequence is complete
		if current_note_index >= sequence_notes.size():
			await handle_win()
		else:
			print("Correct! Continue...")
	else:
		game_over()

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
	disable_all_buttons()
	
	await get_tree().create_timer(2.0).timeout
	current_level += 1
	call_deferred("load_level", current_level)

func game_over():
	# Find the expected note (skip rests)
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
	disable_all_buttons()
	
	await get_tree().create_timer(2.0).timeout
	call_deferred("load_level", current_level)

func disable_all_buttons():
	for i in range(1, 9):
		var button = button_container.get_node("Button" + str(i))
		if button:
			button.set_disabled(true)

func enable_all_buttons():
	for i in range(1, 9):
		var button = button_container.get_node("Button" + str(i))
		if button:
			button.set_disabled(false)
