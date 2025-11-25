extends Area2D

@export var next_scene: String = "res://scenes/scene_transition.tscn"

func _ready() -> void:
	# Set collision layers and masks to ensure detection
	collision_layer = 1  # This area is on layer 1
	collision_mask = 2   # This area detects objects on layer 2 (the player)
	
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	print("Transition area ready - monitoring: ", monitoring)
	print("Area collision_layer: ", collision_layer)
	print("Area collision_mask: ", collision_mask)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)
	print("Body type: ", body.get_class())
	
	# Since we're using collision layers, we can be more confident it's the player
	print("Transition area triggered!")
	monitoring = false
	TransitionManager.transition_to_scene(next_scene)
