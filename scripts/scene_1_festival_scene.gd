extends Node2D

var character_animations := {}  # leave it empty for now

func _ready():
	character_animations = {
		"Tristan": $Tristan,
		"Elia": $Elia
	}

	DialogueManager.got_dialogue.connect(_on_got_dialogue)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	await get_tree().create_timer(2.0).timeout

	var dialogue_resource = preload("res://dialogue/Festival_Dialogue.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

func _on_got_dialogue(line: DialogueLine):
	var speaker = line.character
	var text = line.text

	print(speaker, ": ", text)

	# Optional: Animate or show dialogue visually
	if speaker in character_animations:
		character_animations[speaker].play("talk")

func _on_dialogue_ended():
	for anim in character_animations.values():
		anim.play("idle")
