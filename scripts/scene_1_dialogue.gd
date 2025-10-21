extends Node2D

@export var dialogue_resource: Resource
@export var conversation_id: String = "start"

func _ready():
	DialogueManager.show_dialogue_balloon(dialogue_resource, conversation_id)
