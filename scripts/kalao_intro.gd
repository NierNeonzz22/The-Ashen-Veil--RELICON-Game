extends Node2D

func _ready():
	var anim_player = $AnimationPlayer  # Adjust path if neededaaaaaaaaaaaaaaaaaaaaaadd
	if anim_player:
		# Play a specific animation (replace "your_animation_name" with the actual name)
		anim_player.play("kalao")
		await anim_player.animation_finished
		TransitionManager.transition_to_scene("res://scenes/minigame2test.tscn")
