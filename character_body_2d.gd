#made by jared, mag reklamo ka sa kanya kung may problems / concerns

extends CharacterBody2D

@export var speed = 200.0 

var base_speed = 200.0
var run_bonus = 100.0
var static_body: StaticBody2D
var sprite: Sprite2D
var proximity_distance = 200
var rock_hidden = false
#run speed

@onready var _animation_sprite = $AnimatedSprite2D
@export var static_body_rock: StaticBody2D

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
		speed = base_speed + run_bonus
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
		
	if Input.is_action_just_pressed("ui_Interact") and is_player_near() and not rock_hidden:
		sprite.visible = false
		rock_hidden = true

	#KRILL ME PAUSE MENU (TODO: MAKE NEW SCENE PAUSE MENU) DEPENDENT, SWITCHES SCENES!!!

#ends the script, idk
func _physics_process(_delta):
	get_input()
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody2D:
			var push_dir = -collision.get_normal()
			var push_strength = 50  # increase this for more force
			collider.apply_impulse(push_dir * push_strength)
			
			
func _ready():
	if static_body:
		sprite = static_body.get_node("Rock1")

#interaction script, run on black magic... jk
func is_player_near() -> bool:
	var player_position = global_position
	var static_body_position = static_body.global_position #fist 2 lines handles player position for range detection
	var distance = player_position.distance_to(static_body_position) #player distance to the static body
	return distance <= proximity_distance #if within proxy distance return a boolean value
	
