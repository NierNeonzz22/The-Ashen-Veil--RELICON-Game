extends Control

@onready var start_button: Button = $UI/StartButton
@onready var quit_button: Button = $UI/QuitButton
@onready var background_music: AudioStreamPlayer2D = $BackgroundMusic
@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	print("=== DEBUG INFO ===")
	print("TransitionManager exists: ", has_node("/root/TransitionManager"))
	
	if has_node("/root/TransitionManager"):
		var tm = get_node("/root/TransitionManager")
		print("TransitionManager methods:")
		print("- has transition_to_scene: ", tm.has_method("transition_to_scene"))
		print("- has setup_transition: ", tm.has_method("setup_transition"))
	else:
		print("ERROR: TransitionManager not found in Globals/Autoload!")
	
	# Connect the quit button signal
	if quit_button:
		if not quit_button.pressed.is_connected(_on_quit_button_pressed):
			quit_button.pressed.connect(_on_quit_button_pressed)
		print("Quit button connected")
	else:
		print("ERROR: Quit button not found!")
	
	# Initialize and start fade in
	initialize_fade_in()
	
	# Play background music after fade starts
	play_background_music()

func initialize_fade_in() -> void:
	# Create fade rect if it doesn't exist
	if not fade_rect:
		fade_rect = ColorRect.new()
		fade_rect.name = "FadeRect"
		fade_rect.color = Color.WHITE
		fade_rect.size = get_viewport().get_visible_rect().size
		fade_rect.anchor_left = 0
		fade_rect.anchor_top = 0
		fade_rect.anchor_right = 1
		fade_rect.anchor_bottom = 1
		fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fade_rect)
		move_child(fade_rect, 0)  # Move to bottom so it's behind UI
	
	# Set initial state - fully white
	fade_rect.color = Color.WHITE
	fade_rect.show()
	
	# Disable UI interactions during fade
	set_ui_interactive(false)
	
	# Start 1-second fade out animation
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(1, 1, 1, 0), 3.5)
	tween.tween_callback(_on_fade_in_complete)

func _on_fade_in_complete() -> void:
	fade_rect.hide()
	set_ui_interactive(true)
	print("Fade in complete - UI now interactive")

func set_ui_interactive(interactive: bool) -> void:
	if start_button:
		start_button.disabled = !interactive
	if quit_button:
		quit_button.disabled = !interactive

func play_background_music() -> void:
	if background_music:
		background_music.play()
		print("Background music started")
	else:
		print("WARNING: Background music node not found!")

func _on_start_button_pressed() -> void:
	print("Start button pressed!")
	start_button.disabled = true
	
	# REMOVED: Don't stop music here - let TransitionManager handle it
	# The transition scene will fade out audio over 1.5 seconds
	
	if has_node("/root/TransitionManager"):
		print("Calling TransitionManager...")
		TransitionManager.transition_to_scene("res://scenes/cutscene_1.tscn")
	else:
		print("ERROR: TransitionManager not available!")
		# Fallback - direct scene change (only stop music here as backup)
		if background_music and background_music.playing:
			background_music.stop()
		get_tree().change_scene_to_file("res://scenes/cutscene_1.tscn")

func _on_quit_button_pressed() -> void:
	print("Quit button pressed!")
	quit_button.disabled = true
	
	# Quit the game
	get_tree().quit()
