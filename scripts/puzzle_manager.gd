extends Node

@export var pillars: Array[NodePath] = []
@export var game_time: float = 120.0
@export var gem_scene: PackedScene
@export var gem_spawn_position: Vector2 = Vector2(571, 387)

# Instruction label integration
@export var instruction_label_scene: PackedScene  # Assign your label scene here
@export var instruction_display_time: float = 8.0  # How long to show instructions

# Timer UI integration
@export var timer_ui_scene: PackedScene

var instruction_instance: Node2D = null
var timer_ui_instance: Node2D = null
var game_timer: Timer
var game_active: bool = false
var time_remaining: float = 0.0
var gem_instance: Node2D = null

signal puzzle_completed
signal puzzle_failed

func _ready():
	_remove_existing_gem()
	_connect_pillar_signals()
	_setup_timer()
	
	# Start the game immediately when scene loads using call_deferred
	call_deferred("start_minigame")
	print("Puzzle Manager Ready - Game Starting Immediately")

func _remove_existing_gem():
	var existing_gem = get_parent().get_node_or_null("Gem_1")
	if existing_gem:
		print("🗑️ Found existing gem in scene - removing it!")
		existing_gem.queue_free()

func _setup_timer():
	game_timer = Timer.new()
	add_child(game_timer)
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_timeout)

func start_minigame():
	if game_active:
		return
		
	game_active = true
	time_remaining = game_time
	game_timer.start(game_time)
	
	# Setup timer UI using call_deferred
	if timer_ui_scene:
		timer_ui_instance = timer_ui_scene.instantiate()
		get_parent().add_child.call_deferred(timer_ui_instance)
		print("Timer UI created for light puzzle")
	
	_update_timer_display()
	
	# Reset pillars
	for path in pillars:
		var pillar = get_node(path)
		if pillar and pillar.has_method("unlight"):
			pillar.unlight()
	
	# Enable light source
	var light_source = get_node("../LightSource")
	if light_source and light_source.has_method("enable_light"):
		light_source.enable_light()
	
	# Show instructions immediately using call_deferred
	call_deferred("show_instructions")
	
	print("🎮 Minigame Started")
	set_process(true)

func show_instructions():
	if not instruction_label_scene:
		print("❌ No instruction label scene assigned!")
		return
	
	# Remove existing instructions if any
	if instruction_instance:
		instruction_instance.queue_free()
	
	# Create new instruction label using call_deferred
	instruction_instance = instruction_label_scene.instantiate()
	get_parent().add_child.call_deferred(instruction_instance)
	
	# Use call_deferred for setting up the label to ensure it's ready
	call_deferred("_setup_instruction_label")

func _setup_instruction_label():
	if not instruction_instance:
		return
	
	# Wait for the instruction instance to be fully ready
	await get_tree().process_frame
	
	# Set the text and display time
	if instruction_instance.has_method("set_instruction_text"):
		instruction_instance.set_instruction_text("Arrange the pillars to form \nan octagon light pattern! \nPush pillars using WASD keys\nPress E to pull")
	
	if instruction_instance.has_method("set_display_time"):
		instruction_instance.set_display_time(instruction_display_time)
	
	# Make sure it's visible and plays slide animation
	if instruction_instance.has_method("show_instructions"):
		instruction_instance.show_instructions()
	
	print("📝 Showing puzzle instructions")

func _process(delta):
	if game_active:
		time_remaining -= delta
		_update_timer_display()
		
		if time_remaining <= 0:
			game_active = false
			set_process(false)

func _update_timer_display():
	# Only update if timer UI exists and is in the scene tree
	if timer_ui_instance and timer_ui_instance.is_inside_tree():
		# Use call_deferred to ensure TimerUI is ready
		call_deferred("_safe_update_timer")

func _safe_update_timer():
	# This runs deferred to ensure TimerUI is fully ready
	if timer_ui_instance and timer_ui_instance.has_method("update_time"):
		timer_ui_instance.update_time(time_remaining)
	
	# Optional: Print time every 10 seconds for debugging
	if int(time_remaining) % 10 == 0 and time_remaining > 0:
		var minutes = int(time_remaining) / 60
		var seconds = int(time_remaining) % 60
		print("Light Puzzle Time: %02d:%02d" % [minutes, seconds])

func _connect_pillar_signals():
	for path in pillars:
		var pillar = get_node(path)
		if pillar and not pillar.is_connected("lit_changed", _on_pillar_lit_changed):
			pillar.connect("lit_changed", _on_pillar_lit_changed)

func _on_pillar_lit_changed(pillar):
	if game_active:
		_check_all_lit()

func _check_all_lit():
	for path in pillars:
		var pillar = get_node(path)
		if pillar and not pillar.is_lit:
			return
	
	# All pillars are lit - puzzle solved!
	game_active = false
	game_timer.stop()
	set_process(false)
	
	# Clean up timer UI
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	# Disable light source
	var light_source = get_node("../LightSource")
	if light_source and light_source.has_method("disable_light"):
		light_source.disable_light()
	
	print("🎉 Puzzle Solved!")
	_spawn_gem()
	
	# Show win instructions using call_deferred
	call_deferred("show_instructions")
	
	# Emit completion signal
	puzzle_completed.emit()
	
	# TRANSITION TO WIN SCENE after a delay
	await get_tree().create_timer(3.0).timeout
	TransitionManager.transition_to_scene("res://scenes/win_scene_(namaru).tscn")

func _on_timeout():
	game_active = false
	set_process(false)
	
	# Clean up timer UI
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	print("⏰ Time's Up!")
	
	# Show lose instructions using call_deferred
	call_deferred("show_instructions")
	
	# Emit failure signal
	puzzle_failed.emit()
	
	# TRANSITION TO LOSE SCENE after a delay
	await get_tree().create_timer(3.0).timeout
	TransitionManager.transition_to_scene("res://scenes/lose_scene_(namaru).tscn")

func _spawn_gem():
	if not gem_scene or gem_instance:
		return
	 
	gem_instance = gem_scene.instantiate()
	# Use call_deferred for adding the gem
	get_parent().add_child.call_deferred(gem_instance)
	# Set position after adding
	call_deferred("_set_gem_position")

func _set_gem_position():
	if gem_instance:
		gem_instance.global_position = gem_spawn_position
		gem_instance.name = "Gem_1"
		print("💎 Gem spawned at center: ", gem_spawn_position)

func _restart_game():
	print("🔄 Restarting game...")
	
	# Reset everything
	_reset_game_state()
	
	# Restart the game immediately using call_deferred
	call_deferred("start_minigame")

func _reset_game_state():
	# Reset pillars
	for path in pillars:
		var pillar = get_node(path)
		if pillar and pillar.has_method("unlight"):
			pillar.unlight()
	
	# Remove gem
	if gem_instance:
		gem_instance.queue_free()
		gem_instance = null
	
	# Disable light
	var light_source = get_node("../LightSource")
	if light_source and light_source.has_method("disable_light"):
		light_source.disable_light()
	
	# Reset player position
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = Vector2(300, 300)

func get_remaining_time() -> float:
	return time_remaining

func stop_minigame():
	game_active = false
	set_process(false)
	if game_timer:
		game_timer.stop()
	
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
