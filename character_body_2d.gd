#made by jared, mag reklamo ka sa kanya kung may problems / concerns

extends CharacterBody2D

@export var speed = 100.0 

var base_speed = 100.0
var run_bonus = 50.0
#run speed

@onready var _animation_sprite = $AnimatedSprite2D

# #base movement
func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down") #CHANGE TO KEYMAPS
	velocity = input_direction * speed

#prevents diagonal movement
	if Input.is_action_pressed("Right") or Input.is_action_pressed("Left"): #KEYMAPS
		velocity.y = 0
	elif Input.is_action_pressed("Up") or Input.is_action_pressed("Down"): #KEYMAPS AGAIN
		velocity.x = 0
	else:
		velocity = Vector2.ZERO

#run function
	if Input.is_action_pressed("Run"): #KEYMAPS
		speed = speed + run_bonus
	elif Input.is_action_just_released("Run"): #KEYMAPS
		speed = base_speed

	
# this is for playing animations, the rights and left on is action pressed should be the name of the action in kep maps in project settings
# also animation sprite play must be the same name of the animation in sprite player!!!
# P.S. func delta reads every frame!
func _process(_delta):
	if Input.is_action_pressed("Right"): #KEYMAPS
		_animation_sprite.play("Right") #KEYMAPS
	elif Input.is_action_pressed("Left"): #KEYMAPS
		_animation_sprite.play("Left") #KEYMAPS
	elif Input.is_action_pressed("Down"): #KEYMAPS
		_animation_sprite.play("Down") #KEYMAPS	
	elif Input.is_action_pressed("Up"): #KEYMAPS
		_animation_sprite.play("Up") #KEYMAPS
	
	#replace with _animation_sprite.play("idle") if may idle anim
	else:
		_animation_sprite.stop()

	#KRILL ME PAUSE MENU (TODO: MAKE NEW SCENE PAUSE MENU) DEPENDENT, SWITCHES SCENES!!!

#ends the script, idk
func _physics_process(_delta):
	get_input()
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody2D:
			# Get the push direction and strength
			var push_dir = -collision.get_normal()
			var push_strength = 50  # increase this for more force
			collider.apply_impulse(push_dir * push_strength)
