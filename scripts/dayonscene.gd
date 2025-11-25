extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Just wait for the RESET animation to finish (it's already playing)
	await anim_player.animation_finished
	
	# Then transition to scene_4.tscn
	TransitionManager.transition_to_scene("res://scenes/scene_4.tscn")
