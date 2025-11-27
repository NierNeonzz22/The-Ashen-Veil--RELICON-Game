extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Play the LOSE animation and wait for it to finish
	anim_player.play("dayon lose")
	await anim_player.animation_finished
	
	# Then transition back to Minigame 1
	TransitionManager.transition_to_scene("res://scenes/minigame5.tscn")
