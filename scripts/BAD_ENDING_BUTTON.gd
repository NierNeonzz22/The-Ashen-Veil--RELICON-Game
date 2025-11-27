extends Button

@export var cutscene_path: String = "res://scenes/scene_4_cutscene_(free_yourself).tscn"

func _ready() -> void:
	# Connect the pressed signal
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Cutscene button pressed!")
	
	# Disable button to prevent multiple clicks during transition
	disabled = true
	
	# Use the global transition manager
	TransitionManager.transition_to_scene(cutscene_path)
