extends Node2D

@export var dialogue_resource: DialogueResource
@export var conversation_id := "start"

func _ready():
	DialogueManager.show_dialogue_balloon(dialogue_resource, conversation_id)
