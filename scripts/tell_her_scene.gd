extends Node2D

func _ready() -> void:
	# Wait for the "Do not tell her scene" animation to finish
	$AnimationPlayer.play("tell her scene")
	await $AnimationPlayer.animation_finished
	
	# Transition to the next game scene
	TransitionManager.transition_to_scene("res://scenes/minigame4_Test2.tscn")
