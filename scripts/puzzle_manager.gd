extends Node

@export var pillars: Array[NodePath] = []
@export var win_dialogue_resource: DialogueResource
@export var lose_dialogue_resource: DialogueResource
@export var game_time: float = 120.0
@export var gem_scene: PackedScene
@export var gem_spawn_position: Vector2 = Vector2(571, 387)

# Timer UI integration
@export var timer_ui_scene: PackedScene
var timer_ui_instance: Node2D = null

# White fade transition - assign your WhiteFade.tscn here
@export var fade_scene: PackedScene
var fade_instance: ColorRect = null

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
	print("Puzzle Manager Ready")

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
	
	if timer_ui_scene:
		timer_ui_instance = timer_ui_scene.instantiate()
		get_parent().add_child(timer_ui_instance)
		print("Timer UI created for light puzzle")
	
	_update_timer_display()
	
	for path in pillars:
		var pillar = get_node(path)
		if pillar and pillar.has_method("unlight"):
			pillar.unlight()
	
	var light_source = get_node("../LightSource")
	if light_source and light_source.has_method("enable_light"):
		light_source.enable_light()
	
	print("🎮 Minigame Started")
	set_process(true)

func _process(delta):
	if game_active:
		time_remaining -= delta
		_update_timer_display()
		
		if time_remaining <= 0:
			game_active = false
			set_process(false)

func _update_timer_display():
	if timer_ui_instance and timer_ui_instance.has_method("update_time"):
		timer_ui_instance.update_time(time_remaining)
	
	if int(time_remaining) % 10 == 0:
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
	
	game_active = false
	game_timer.stop()
	set_process(false)
	
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	var light_source = get_node("../LightSource")
	if light_source and light_source.has_method("disable_light"):
		light_source.disable_light()
	
	print("🎉 Puzzle Solved!")
	_spawn_gem()
	_trigger_win_dialogue()

func _spawn_gem():
	if not gem_scene or gem_instance:
		return
	 
	gem_instance = gem_scene.instantiate()
	get_parent().add_child(gem_instance)
	gem_instance.global_position = gem_spawn_position
	gem_instance.name = "Gem_1"
	
	print("💎 Gem spawned at center: ", gem_spawn_position)

func _trigger_win_dialogue():
	if win_dialogue_resource:
		DialogueManager.show_example_dialogue_balloon(win_dialogue_resource, "start")

func _on_timeout():
	game_active = false
	set_process(false)
	
	if timer_ui_instance:
		timer_ui_instance.queue_free()
		timer_ui_instance = null
	
	print("⏰ Time's Up!")
	_trigger_lose_dialogue()

func _trigger_lose_dialogue():
	if lose_dialogue_resource:
		# FIX: Use "start" instead of "LOSE" since all dialogues use ~ start
		DialogueManager.show_example_dialogue_balloon(lose_dialogue_resource, "start")
		# Wait for dialogue to finish, then restart with white fade
		await get_tree().create_timer(1.0).timeout
		_restart_game()

func _restart_game():
	print("🔄 Restarting game...")
	
	# Start white fade out
	_show_white_fade()
	
	# Wait for fade out
	await get_tree().create_timer(1.0).timeout
	
	# Reset everything
	_reset_game_state()
	
	# Wait 2 seconds on white screen
	await get_tree().create_timer(2.0).timeout
	
	# Fade in
	_hide_white_fade()
	
	# Wait for fade in
	await get_tree().create_timer(1.0).timeout
	
	# Restart the game (trigger dialogue again)
	_restart_dialogue()

func _show_white_fade():
	print("🎬 Showing white fade...")
	if fade_scene:
		fade_instance = fade_scene.instantiate()
		get_parent().add_child(fade_instance)
		print("✅ White fade scene instantiated")
		# Play fade out animation
		if fade_instance.has_node("AnimationPlayer"):
			var anim_player = fade_instance.get_node("AnimationPlayer")
			if anim_player.has_animation("fade_out"):
				anim_player.play("fade_out")
				print("🎬 Playing fade_out animation")
			else:
				print("❌ No fade_out animation found!")
	else:
		print("❌ No fade_scene assigned!")

func _hide_white_fade():
	print("🎬 Hiding white fade...")
	if fade_instance and fade_instance.has_node("AnimationPlayer"):
		var anim_player = fade_instance.get_node("AnimationPlayer")
		if anim_player.has_animation("fade_in"):
			print("🎬 Playing fade_in animation")
			anim_player.play("fade_in")
			await anim_player.animation_finished
			print("✅ fade_in animation finished")
	
	if fade_instance:
		fade_instance.queue_free()
		fade_instance = null
		print("✅ White fade removed")

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

func _restart_dialogue():
	# Trigger the initial dialogue again
	var dialogue_trigger = get_tree().get_first_node_in_group("dialogue_trigger")
	if dialogue_trigger and dialogue_trigger.has_method("trigger_dialogue"):
		dialogue_trigger.trigger_dialogue()
	else:
		start_minigame()

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
