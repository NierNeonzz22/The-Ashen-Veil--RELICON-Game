extends RigidBody2D

# Declare the nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

# This function will be called when the body enters the Area2D
func _on_Area2D_body_entered(body):
	if body == self:
		# Change the animation when entering the area
		animated_sprite.play("lit")

func _on_Area2D_body_exited(body):
	if body == self:
		# Change back to the original animation
		animated_sprite.play("original_animation")  # Replace with your original animation
