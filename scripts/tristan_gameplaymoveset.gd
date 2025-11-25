extends CharacterBody2D

@export var base_speed := 200.0
@export var run_bonus := 100.0
@export var push_strength := 60.0

var facing_direction := Vector2.DOWN
var is_moving := false
@onready var anim := $AnimatedSprite2D

func _physics_process(delta):
	var input_vector := Vector2.ZERO

	# Input
	if Input.is_action_pressed("Right"): input_vector.x = 1
	elif Input.is_action_pressed("Left"): input_vector.x = -1
	if Input.is_action_pressed("Down"): input_vector.y = 1
	elif Input.is_action_pressed("Up"): input_vector.y = -1

	# Prevent diagonal movement
	if abs(input_vector.x) > abs(input_vector.y):
		input_vector.y = 0
	else:
		input_vector.x = 0

	# Update movement state and facing direction
	is_moving = input_vector != Vector2.ZERO
	if is_moving:
		facing_direction = input_vector

	# Running speed
	var speed := base_speed
	if Input.is_action_pressed("Run"):
		speed += run_bonus

	velocity = input_vector * speed
	move_and_slide()

	_handle_push_collisions(delta)
	_update_animation()

func _handle_push_collisions(delta):
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var obj = collision.get_collider()

		if obj is CharacterBody2D and obj.has_method("push"):
			var dir = -collision.get_normal()
			obj.push(dir, delta)  # use CharacterBody2D push method

func _update_animation():
	if is_moving:
		# Play movement animations based on direction
		if facing_direction == Vector2.RIGHT: anim.play("Right")
		elif facing_direction == Vector2.LEFT: anim.play("Left")
		elif facing_direction == Vector2.UP: anim.play("Up")
		elif facing_direction == Vector2.DOWN: anim.play("Down")
	else:
		# Play idle animations based on last facing direction
		if facing_direction == Vector2.RIGHT: anim.play("Idle_Right")
		elif facing_direction == Vector2.LEFT: anim.play("Idle_Left")
		elif facing_direction == Vector2.UP: anim.play("Idle_Up")
		elif facing_direction == Vector2.DOWN: anim.play("Idle_Down")

func _input(event):
	if event.is_action_pressed("pull"):
		_attempt_pull_start()
	elif event.is_action_released("pull"):
		_attempt_pull_stop()

# -------------------------
# PULL SYSTEM
# -------------------------

func _attempt_pull_start():
	var ray_from = global_position
	var ray_to = global_position + facing_direction * 40

	var params := PhysicsRayQueryParameters2D.new()
	params.from = ray_from
	params.to = ray_to
	params.exclude = [self]
	params.collide_with_bodies = true

	var result = get_world_2d().direct_space_state.intersect_ray(params)

	if result.is_empty():
		return

	var obj = result["collider"]
	if obj is CharacterBody2D and obj.has_method("start_pull"):
		obj.start_pull(-facing_direction)

func _attempt_pull_stop():
	var ray_from = global_position
	var ray_to = global_position + facing_direction * 40

	var params := PhysicsRayQueryParameters2D.new()
	params.from = ray_from
	params.to = ray_to
	params.exclude = [self]
	params.collide_with_bodies = true

	var result = get_world_2d().direct_space_state.intersect_ray(params)

	if result.is_empty():
		return

	var obj = result["collider"]
	if obj is CharacterBody2D and obj.has_method("stop_pull"):
		obj.stop_pull()
