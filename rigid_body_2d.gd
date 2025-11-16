extends RigidBody2D
@onready var _animation_sprite = get_node("/root/Scene/R/AnimatedSprite2D")

_animation_sprite.play("unlit")
