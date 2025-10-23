extends Node2D   # or Control, depending on your scene root

@export var dialogue_resource: Resource
@export var conversation_id: String = "start"

@onready var fade_layer: ColorRect = $FadeLayer
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# start with full white screen
	fade_layer.modulate.a = 1.0
	fade_layer.mouse_filter = Control.MOUSE_FILTER_STOP

	# play fade-in animation (from white → visible)
	anim.play("fade_in")
	await anim.animation_finished

	# wait 2 seconds before dialogue
	await get_tree().create_timer(2.0).timeout

	# now show the dialogue
	DialogueManager.show_dialogue_balloon(dialogue_resource, conversation_id)

	# allow input again
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
