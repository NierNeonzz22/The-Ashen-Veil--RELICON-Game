extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Play the lose animation and wait for it to finish
	anim_player.play("LOSE option")  # Change to your actual animation name
	await anim_player.animation_finished
	
	# Then transition back to minigame 2
	print("Returning to minigame 2...")
	TransitionManager.transition_to_scene("res://scenes/Minigame 2.tscn")
