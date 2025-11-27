extends Node2D

func _ready():
	var anim_player = $AnimationPlayer  # Adjust path if neededaaaaaaaaaaaaaaaaaaaaaadd
	if anim_player:
		# Play a specific animation (replace "your_animation_name" with the actual name)
		anim_player.play("FLASH")
		await anim_player.animation_finished
		print("Animation finished - transitioning to cutscene_3.tscn")
		
		# Transition to the next scene
		TransitionManager.transition_to_scene("res://scenes/cutscene_3.tscn")
	else:
		print("AnimationPlayer node not found")
		# Fallback: transition immediately
		TransitionManager.transition_to_scene("res://scenes/cutscene_3.tscn")
