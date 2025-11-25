extends Node2D

func _ready():
	var anim_player = $AnimationPlayer  # Adjust path if needed
	if anim_player:
		var anim_list = anim_player.get_animation_list()
		if anim_list.size() > 0:
			print("Animations found: ", anim_list)
		else:
			print("No animations in AnimationPlayer")
	else:
		print("AnimationPlayer node not found")
