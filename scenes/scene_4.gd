extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Wait for the RESET animation to finish
	await anim_player.animation_finished
	TransitionManager.transition_to_scene("res://scenes/Dialogue 4.tscn")
