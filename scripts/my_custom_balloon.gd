extends CanvasLayer

@onready var dialogue_label = $Balloon/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/DialogueLabel
@onready var name_label = $Balloon/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/CharacterLabel

var dialogue_resource: DialogueResource
var title: String
var extra_game_states: Array

func start(resource: DialogueResource, initial_title: String, initial_states: Array) -> void:
	dialogue_resource = resource
	title = initial_title
	extra_game_states = initial_states
	
	set_process_input(true)
	await get_tree().process_frame
	_next()

func _next() -> void:
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(dialogue_resource, title, extra_game_states)
	
	if not line:
		queue_free()
		return
	
	_update_balloon(line)

func _update_balloon(line: DialogueLine) -> void:
	name_label.text = line.character
	dialogue_label.text = line.text
	
	# If this dialogue has choices but we don't support them, show error
	if line.responses.size() > 0:
		print("ERROR: This dialogue has choices but no responses menu is setup!")
		queue_free()
	# Otherwise, just wait for click to continue

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled()
		_next()
