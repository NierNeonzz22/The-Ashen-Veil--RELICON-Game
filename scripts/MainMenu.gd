extends Control

@onready var start_button: Button = $UI/StartButton

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

func _on_start_button_pressed() -> void:
	print("Start button pressed!")
	start_button.disabled = true
	
	if has_node("/root/TransitionManager"):
		print("Calling TransitionManager...")
		TransitionManager.transition_to_scene("res://scenes/cutscene_1.tscn")
	else:
		print("ERROR: TransitionManager not available!")
		# Fallback - direct scene change
		get_tree().change_scene_to_file("res://scenes/cutscene_1.tscn")
