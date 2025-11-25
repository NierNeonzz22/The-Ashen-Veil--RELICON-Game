extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Play the "WIN scene" animation and wait for it to finish
	anim_player.play("WIN scene")
	await anim_player.animation_finished
	
	# Then transition to Kalao Intro.tscn
	TransitionManager.transition_to_scene("res://scenes/Kalao Intro.tscn")
