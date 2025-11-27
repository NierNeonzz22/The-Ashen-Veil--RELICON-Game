extends Node2D

@onready var inventory_panel: ColorRect = $"ColorRect" 
@onready var timer = $Timer
@onready var label = $Label
var countdown_time = 180  # replace this with however long it needs to be
var current_time = countdown_time

# Add instruction label reference
@export var instruction_label_scene: PackedScene  # Assign your Label_instruction.tscn in inspector
@export var timer_ui_scene: PackedScene  # Assign your TimerUI.tscn in inspector
var instruction_instance: Node2D = null
var timer_ui_instance: Node2D = null

@onready var draggable_objects: Array = [
	$"Sprite2D2", $"Sprite2D3", $"Sprite2D4",
	$"Sprite2D5", $"Sprite2D6", $"Sprite2D7", $"Sprite2D8"
]

# Reset positions
@onready var reset_positions := {
	"Sprite2D2": Vector2(150, 50),
	"Sprite2D3": Vector2(250, 50),
	"Sprite2D4": Vector2(350, 50),
	"Sprite2D5": Vector2(450, 50),
	"Sprite2D6": Vector2(550, 50),
	"Sprite2D7": Vector2(650, 50),
	"Sprite2D8": Vector2(750, 50)
}

# Slots
@onready var slots: Array = [
	$"Node2D2/Slot1",
	$"Node2D2/Slot2",
	$"Node2D2/Slot3",
	$"Node2D2/Slot4",
	$"Node2D2/Slot5",
	$"Node2D2/Slot6",
	$"Node2D2/Slot7"
]

# SLOT → correct sprite mapping
var slot_targets := {
	"Slot1": "Sprite2D7",
	"Slot2": "Sprite2D5",
	"Slot3": "Sprite2D8",
	"Slot4": "Sprite2D2",
	"Slot5": "Sprite2D4",
	"Slot6": "Sprite2D3",
	"Slot7": "Sprite2D6"
}

# ROCK → unlocks which sprite
var unlocks := {
	"Rock1": "Sprite2D7",
	"Rock2": "Sprite2D5",
	"Rock3": "Sprite2D8",
	"Rock4": "Sprite2D2",
	"Rock5": "Sprite2D4",
	"Rock6": "Sprite2D3",
	"Rock7": "Sprite2D6"
}

# tracks items unlocked by rocks
var unlocked_items := {}

# For tracking correct placements
var correct_placements := 0
var total_placements := 7  # Total number of slots that need to be filled correctly

var selected_sprite: Sprite2D = null
var mouse_offset: Vector2 = Vector2.ZERO
var is_inventory_open := false
var timer_running := true  # Flag to control timer state

# ADD THIS: Prevent multiple lose calls
var game_ended := false


###############################
# INITIAL SETUP
###############################
func _ready():
	inventory_panel.visible = false
	
	for obj in draggable_objects:
		obj.visible = false  # invisible until unlocked

	for slot in slots:
		slot.visible = false
		var highlight = slot.get_node("Highlight")
		highlight.color = Color(1, 0, 0, 0.4)

	$"ColorRect/ResetButton".visible = false
	$"ColorRect/ResetButton".pressed.connect(_on_reset_pressed)
	
	# Setup timer UI instead of using the label
	setup_timer_ui()
	
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	
	#timer interval of 1 second 
	timer.start(countdown_time)
	
	# Show sequential instructions when game starts
	show_sequential_instructions()


###############################
# TIMER UI SETUP
###############################
func setup_timer_ui():
	if timer_ui_scene:
		# Create timer UI instance
		timer_ui_instance = timer_ui_scene.instantiate()
		add_child(timer_ui_instance)
		print("Timer UI created")
		
		# Update timer display immediately
		update_timer_display()
	else:
		print("Warning: No Timer UI scene assigned, using fallback label")
		label.text = str(current_time)


###############################
# SEQUENTIAL INSTRUCTION SYSTEM
###############################
func show_sequential_instructions():
	if instruction_label_scene:
		# FIRST INSTRUCTION: Show for 10 seconds
		await show_instruction("Find letters in the rocks and assemble them in the right order!", 10.0)
		
		# Wait for first instruction to complete
		await get_tree().create_timer(10.0).timeout
		
		# Smooth transition: Slide out first instruction
		await hide_current_instruction()
		
		# Brief pause between transitions
		await get_tree().create_timer(0.5).timeout
		
		# SECOND INSTRUCTION: Show for 30 seconds
		await show_instruction("E - Interact with rock\nF - Open inventory to assemble", 30.0)

func show_instruction(text: String, duration: float):
	if instruction_label_scene:
		# Remove any existing instruction
		if instruction_instance:
			instruction_instance.queue_free()
		
		# Create new instruction label instance
		instruction_instance = instruction_label_scene.instantiate()
		add_child(instruction_instance)
		print("Showing instruction: ", text)
		
		# Set the instruction text
		if instruction_instance.has_method("set_instruction_text"):
			instruction_instance.set_instruction_text(text)
		
		# Set display duration
		if instruction_instance.has_method("set_display_time"):
			instruction_instance.set_display_time(duration)
		
		# Play slide in animation and wait for it to complete
		if instruction_instance.has_method("show_instructions"):
			instruction_instance.show_instructions()
		elif instruction_instance.has_node("AnimationPlayer"):
			var anim_player = instruction_instance.get_node("AnimationPlayer")
			if anim_player.has_animation("slide_left"):
				anim_player.play("slide_left")
				await anim_player.animation_finished

func hide_current_instruction():
	if instruction_instance:
		print("Hiding current instruction with slide_right animation")
		# Play slide out animation and wait for it to complete
		if instruction_instance.has_method("hide_instructions"):
			instruction_instance.hide_instructions()
			# Wait for the hide_instructions to complete (it should handle the animation)
			await get_tree().create_timer(0.5).timeout
		elif instruction_instance.has_node("AnimationPlayer"):
			var anim_player = instruction_instance.get_node("AnimationPlayer")
			if anim_player.has_animation("slide_right"):
				anim_player.play("slide_right")
				await anim_player.animation_finished
		
		# Remove the instance
		instruction_instance.queue_free()
		instruction_instance = null


###############################
# MAIN UPDATE LOOP
###############################
func _process(delta):
	if Input.is_action_just_pressed("Inventory"):
		toggle_inventory()

	if selected_sprite:
		selected_sprite.position = get_global_mouse_position() + mouse_offset
		
	# Timer code
	if timer_running and not timer.is_stopped():
		current_time = int(timer.time_left)
		update_timer_display()
	elif current_time <= 0 and not game_ended:  # ADDED: Check game_ended flag
		# Time's up - lose condition
		_on_game_lose()


###############################
# TIMER DISPLAY UPDATE
###############################
func update_timer_display():
	# Update the timer UI if it exists
	if timer_ui_instance and timer_ui_instance.has_method("update_time"):
		timer_ui_instance.update_time(current_time)
	else:
		# Fallback to the label if no timer UI
		label.text = str(current_time)


###############################
# INVENTORY TOGGLE
###############################
func toggle_inventory():
	is_inventory_open = !is_inventory_open
	inventory_panel.visible = is_inventory_open
	$"ColorRect/ResetButton".visible = is_inventory_open

	update_inventory_visibility()



###############################
# UPDATE WHAT IS VISIBLE
###############################
func update_inventory_visibility():
	for obj in draggable_objects:
		obj.visible = is_inventory_open and unlocked_items.has(obj.name)

	for slot in slots:
		slot.visible = is_inventory_open



###############################
# ROCK BREAK → UNLOCK ITEM
###############################
func unlock_item_for_rock(rock_name: String):
	if unlocks.has(rock_name):
		var sprite_name = unlocks[rock_name]
		unlocked_items[sprite_name] = true
		print("Unlocked item: ", sprite_name)

		update_inventory_visibility()  # Don't touch



###############################
# DRAGGING SYSTEM
###############################
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			for sprite in draggable_objects:
				if sprite.visible and sprite.get_rect().has_point(sprite.to_local(get_global_mouse_position())):
					selected_sprite = sprite
					mouse_offset = selected_sprite.position - get_global_mouse_position()
					break

		else:
			end_drag()



###############################
# DROP INTO SLOT / SNAP LOGIC
###############################
func end_drag():
	if selected_sprite == null:
		return

	for slot in slots:
		if sprite_over_slot(selected_sprite, slot):

			# Snap into slot
			selected_sprite.global_position = slot.global_position

			# verify correctness
			var required_name = slot_targets.get(slot.name, "")
			var highlight = slot.get_node("Highlight")

			if selected_sprite.name == required_name:
				highlight.color = Color(0, 1, 0, 0.5)  # correct → green
				correct_placements += 1  # Increment correct placements
			else:
				highlight.color = Color(1, 0, 0, 0.5)  # wrong → red

			break

	selected_sprite = null
	check_win_condition()  # Check if all correct items have been placed


###############################
# SLOT COLLISION CHECK
###############################
func sprite_over_slot(sprite: Sprite2D, slot: Area2D) -> bool:
	var shape := slot.get_node("CollisionShape2D").shape as RectangleShape2D
	var half: Vector2 = shape.extents

	var forgiveness := 40  # Adjust to make snapping easier

	var slot_rect := Rect2(
		slot.global_position - half - Vector2(forgiveness, forgiveness),
		(half * 2) + Vector2(forgiveness * 2, forgiveness * 2)
	)

	return slot_rect.has_point(sprite.global_position)



###############################
# RESET BUTTON
###############################
func _on_reset_pressed():
	for obj in draggable_objects:
		if reset_positions.has(obj.name):
			obj.global_position = reset_positions[obj.name]

	for slot in slots:
		slot.get_node("Highlight").color = Color(1, 0, 0, 0.4)
		
func _on_Timer_timeout():
	if current_time <= 0 and not game_ended:  # ADDED: Check game_ended flag
		_on_game_lose()


###############################
# WIN CONDITION
###############################
func check_win_condition():
	if correct_placements == total_placements and not game_ended:  # ADDED: Check game_ended flag
		print("YOU WIN! Transitioning to kalaoscene.tscn")
		_on_game_win()


###############################
# WIN TRANSITION
###############################
func _on_game_win():
	# ADDED: Set game_ended flag
	game_ended = true
	timer_running = false
	timer.stop()
	
	# Clean up timer UI
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	# Wait a moment to show win state, then transition
	await get_tree().create_timer(2.0).timeout
	TransitionManager.transition_to_scene("res://scenes/kalaoscene.tscn")


###############################
# LOSE TRANSITION
###############################
func _on_game_lose():
	# ADDED: Set game_ended flag
	game_ended = true
	timer_running = false
	timer.stop()
	
	# Clean up timer UI
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	print("💀 GAME OVER - Time's up! Transitioning to LOSE scene...")
	
	# Wait a moment to show lose state, then transition
	await get_tree().create_timer(2.0).timeout
	TransitionManager.transition_to_scene("res://scenes/LOSE.tscn")
