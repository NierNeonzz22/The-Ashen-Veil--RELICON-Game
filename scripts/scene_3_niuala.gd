extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Play the lose animation and wait for it to finish
	anim_player.play("niuala scene")  # Change to your actual animation name
	await anim_player.animation_finished
	
	TransitionManager.transition_to_scene("res://scenes/minigame4_Test2.tscn")
