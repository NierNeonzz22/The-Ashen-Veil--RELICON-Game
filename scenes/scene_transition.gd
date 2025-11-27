extends Node2D

func _ready() -> void:
	# Wait for the animation to finish (whichever one ends)
	await $AnimationPlayer.animation_finished
	TransitionManager.transition_to_scene("res://scenes/Cutscene_3.tscn")
