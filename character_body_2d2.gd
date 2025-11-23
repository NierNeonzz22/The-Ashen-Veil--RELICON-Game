extends CharacterBody2D

# ----------------------
# Movement
# ----------------------
@export var speed: float = 200.0
var base_speed: float = 200.0
var run_bonus: float = 100.

@onready var _animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var proximity_distance: float = 100

var rocks: Array[StaticBody2D] = []
var rock_sprites: Dictionary = {}  # key: StaticBody2D, value: {"rock": Sprite2D, "M": Sprite2D}

# ----------------------
# Ready
# ----------------------
func _ready():
	# Get the parent node containing all the rocks
	var rocks_parent = get_tree().get_current_scene().get_node("Rocks")
	
	for rock_node in rocks_parent.get_children():
		if rock_node is StaticBody2D:
			rocks.append(rock_node)
			var rock_sprite = rock_node.get_node("Rock1")
			var m_sprite = rock_node.get_node("M")
			m_sprite.visible = false
			rock_sprites[rock_node] = {"rock": rock_sprite, "M": m_sprite}

# ----------------------
# Input & Movement
# ----------------------
func get_input():
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_dir * speed

	# Prevent diagonal movement
	if Input.is_action_pressed("Right") or Input.is_action_pressed("Left"):
		velocity.y = 0
	elif Input.is_action_pressed("Up") or Input.is_action_pressed("Down"):
		velocity.x = 0
	else:
		velocity = Vector2.ZERO

	# Running
	if Input.is_action_pressed("Run"):
		speed = base_speed + run_bonus
	elif Input.is_action_just_released("Run"):
		speed = base_speed

# ----------------------
# Physics
# ----------------------
func _physics_process(_delta):
	get_input()
	move_and_slide()

# ----------------------
# Animation & Interaction
# ----------------------
func _process(_delta):
	# Movement animations
	if Input.is_action_pressed("Right"):
		_animation_sprite.play("Right")
	elif Input.is_action_pressed("Left"):
		_animation_sprite.play("Left")
	elif Input.is_action_pressed("Down"):
		_animation_sprite.play("Down")
	elif Input.is_action_pressed("Up"):
		_animation_sprite.play("Up")
	else:
		_animation_sprite.stop()

	if Input.is_action_just_pressed("Interact"):
		for rock_node in rocks:
			var rock_data = rock_sprites[rock_node]
			if not rock_data["rock"].visible:
				continue

			var distance = global_position.distance_to(rock_node.global_position)
			if distance <= proximity_distance:

			# Hide the rock + show the M sprite
				rock_data["rock"].visible = false
				rock_data["M"].visible = true

			# --- NEW: Notify inventory puzzle script ---
				var puzzle_script = get_tree().get_root().find_child("Node2D", true, false)
				if puzzle_script:
					puzzle_script.unlock_item_for_rock(rock_node.name)

				break
