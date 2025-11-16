extends Area2D

@onready var _animation_sprite = get_node("/root/Scene/R/AnimatedSprite2D") # Make sure this points to the AnimatedSprite2D node

# Signal handler when a body enters the Area2D
func _on_Area2D_body_entered(body: Node) -> void:
	if body is RigidBody2D:  # Make sure it's a RigidBody2D that enters the area
		_animation_sprite.play("lit")  # Play the animation
