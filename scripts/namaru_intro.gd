extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Play the animation and wait for it to finish
	anim_player.play("namaru intro")
	await anim_player.animation_finished
	
	# Then transition to minigame
	TransitionManager.transition_to_scene("res://scenes/minigame1.tscn")
