extends Node2D

var character_animations := {}

func _ready():
	character_animations = {
		"Tristan": $Tristan,
		"Elia": $Elia
	}

	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# CORRECT: Set through DialogueManager's internal reference
	# OR if that doesn't work, try:
	# DialogueManager.get_dialogue_manager().balloon_scene = preload("res://my_custom_balloon.tscn")

	await get_tree().create_timer(2.0).timeout
	var dialogue_resource = preload("res://dialogue/Festival_Dialogue.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

func _on_dialogue_ended():
	for anim in character_animations.values():
		anim.play("idle")
