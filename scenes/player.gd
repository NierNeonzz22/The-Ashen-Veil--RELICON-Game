extends CharacterBody2D

@export var speed := 150.0

@onready var anim = $AnimatedSprite2D
var is_dead = false


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	update_animation(input_vector)
	

func update_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		anim.stop()
		return

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			anim.play("ui_right")
		else:
			anim.play("ui_left")
	else:
		if dir.y > 0:
			anim.play("ui_down")
		else:
			anim.play("ui_up")
