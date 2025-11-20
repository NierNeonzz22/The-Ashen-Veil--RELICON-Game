extends CharacterBody2D

# --- MOVEMENT SETTINGS ---
@export var grid_step := 32
@export var pull_speed := 150.0
@export var push_strength := 100.0

var is_pulling := false
var pulling_direction := Vector2.ZERO

# --- LIGHTING ---
@export var sprite_unlit: Texture2D
@export var sprite_lit: Texture2D
@export var is_lit := false

signal lit_changed(pillar)

# --- NODES ---
@onready var sprite_node: Sprite2D = $Sprite2D

# ---------------------------
#   START / STOP PULL
# ---------------------------
func start_pull(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	is_pulling = true
	pulling_direction = direction.normalized()

func stop_pull() -> void:
	is_pulling = false

# ---------------------------
#   PHYSICS LOOP
# ---------------------------
func _physics_process(delta: float) -> void:
	if is_pulling:
		var motion := pulling_direction * pull_speed * delta
		_move_safe(motion)

# ---------------------------
#   PUSH: CALLED BY PLAYER
# ---------------------------
func push(direction: Vector2, delta: float) -> void:
	var motion := direction.normalized() * push_strength * delta
	_move_safe(motion)

# ---------------------------
#   SAFE MOVEMENT WRAPPER
# ---------------------------
func _move_safe(motion: Vector2) -> void:
	# convert the motion into proper velocity for CharacterBody2D
	velocity = motion / get_physics_process_delta_time()

	var remainder = move_and_slide()

	# Prevent rotation (CharacterBody2D does not rotate, but just in case)
	rotation = 0

# ---------------------------
#   LIGHTING CONTROL
# ---------------------------
func light_up() -> void:
	if not is_lit:
		is_lit = true
		_update_visual()
		emit_signal("lit_changed", self)

func unlight() -> void:
	if is_lit:
		is_lit = false
		_update_visual()
		emit_signal("lit_changed", self)

func _update_visual() -> void:
	sprite_node.texture = sprite_lit if is_lit else sprite_unlit
