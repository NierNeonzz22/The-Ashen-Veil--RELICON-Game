extends CanvasLayer

signal transition_started
signal transition_completed

var fade_layer: ColorRect
var anim: AnimationPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100  # High layer to be on top of everything
	setup_transition()

func setup_transition() -> void:
	# Create a simple fade layer programmatically (most reliable approach)
	fade_layer = ColorRect.new()
	fade_layer.name = "FadeLayer"
	fade_layer.color = Color.WHITE
	
	# Make it cover the entire screen properly
	fade_layer.anchor_left = 0.0
	fade_layer.anchor_top = 0.0
	fade_layer.anchor_right = 1.0
	fade_layer.anchor_bottom = 1.0
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.modulate.a = 0.0  # Start invisible
	
	# Create animation player
	anim = AnimationPlayer.new()
	anim.name = "TransitionAnim"
	
	# Add to scene tree
	add_child(fade_layer)
	fade_layer.add_child(anim)
	
	# Create simple animations
	create_simple_animations()
	
	print("TransitionManager setup complete - FadeLayer: ", fade_layer != null, " Anim: ", anim != null)
	print("CanvasLayer layer: ", layer)

func create_simple_animations() -> void:
	# Fade out animation (to white) - SLOWER: 1.5 seconds
	var fade_out = Animation.new()
	fade_out.length = 1.5
	
	var track_idx = fade_out.add_track(Animation.TYPE_VALUE)
	# FIXED PATH: AnimationPlayer is child of FadeLayer, so use ":modulate:a"
	fade_out.track_set_path(track_idx, ":modulate:a")
	fade_out.value_track_set_update_mode(track_idx, Animation.UPDATE_CONTINUOUS)
	fade_out.track_insert_key(track_idx, 0.0, 0.0)
	fade_out.track_insert_key(track_idx, 1.5, 1.0)
	
	# Fade in animation (from white) - SLOWER: 1.5 seconds
	var fade_in = Animation.new()
	fade_in.length = 1.5
	
	track_idx = fade_in.add_track(Animation.TYPE_VALUE)
	# FIXED PATH: Same fix here
	fade_in.track_set_path(track_idx, ":modulate:a")
	fade_in.value_track_set_update_mode(track_idx, Animation.UPDATE_CONTINUOUS)
	fade_in.track_insert_key(track_idx, 0.0, 1.0)
	fade_in.track_insert_key(track_idx, 1.5, 0.0)
	
	# Add animations using the new Godot 4 method
	var library = AnimationLibrary.new()
	library.add_animation("fade_out", fade_out)
	library.add_animation("fade_in", fade_in)
	anim.add_animation_library("", library)

func transition_to_scene(scene_path: String) -> void:
	if fade_layer == null:
		push_error("FadeLayer is null! Cannot transition.")
		return
	
	if anim == null:
		push_error("AnimationPlayer is null! Cannot transition.")
		return
	
	print("Starting transition to: ", scene_path)
	transition_started.emit()
	fade_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Fade out (slower - 1.5 seconds)
	print("Starting fade out (1.5 seconds)...")
	anim.play("fade_out")
	await anim.animation_finished
	print("Fade out complete - alpha should be 1.0: ", fade_layer.modulate.a)
	
	# Hold on white screen for 3 seconds
	print("Holding on white screen for 3 seconds...")
	await get_tree().create_timer(3.0).timeout
	print("White screen hold complete")
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	print("Scene changed")
	
	# Fade in (slower - 1.5 seconds)
	print("Starting fade in (1.5 seconds)...")
	anim.play("fade_in")
	await anim.animation_finished
	print("Fade in complete - alpha should be 0.0: ", fade_layer.modulate.a)
	
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_completed.emit()
	print("Transition complete")

# Manual test function - press spacebar to test fade
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Press spacebar
		print("Manual test - toggling fade")
		print("Current alpha: ", fade_layer.modulate.a)
		if fade_layer.modulate.a == 0.0:
			anim.play("fade_out")
		else:
			anim.play("fade_in")
