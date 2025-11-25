extends CharacterBody2D

# --- MOVEMENT SETTINGS ---
@export var grid_step := 32
@export var pull_speed := 150.0
@export var push_strength := 100.0

var is_pulling := false
var pulling_direction := Vector2.ZERO

# --- LIGHTING & REDIRECTION ---
@export var sprite_unlit: Texture2D
@export var sprite_lit: Texture2D
@export var redirect_angle: float = 0.0  # Angle in degrees (0=right, 90=up, 180=left, 270=down)
var is_lit := false

signal lit_changed(pillar)
signal pillar_hit(pillar, redirect_angle)

# --- NODES ---
@onready var sprite_unlit_node: Sprite2D = $Sprite2D
@onready var sprite_lit_node: Sprite2D = $Sprite2D_Lit

func _ready():
	add_to_group("pillar")  # CRITICAL: Add to pillar group
	$CollisionShape2D.disabled = false
	unlight()
	print(name, " redirects at angle: ", redirect_angle, "°")

# ---------------------------
#   LIGHTING CONTROL
# ---------------------------
func light_up() -> void:
	if not is_lit:
		is_lit = true
		_update_visual()
		emit_signal("lit_changed", self)
		emit_signal("pillar_hit", self, redirect_angle)
		print(name, " is now LIT!")

func unlight() -> void:
	if is_lit:
		is_lit = false
		_update_visual()
		emit_signal("lit_changed", self)
		print(name, " is now UNLIT!")
		
func _update_visual() -> void:
	if sprite_unlit_node and sprite_lit_node:
		sprite_unlit_node.visible = not is_lit
		sprite_lit_node.visible = is_lit
	else:
		print("ERROR: Sprite nodes not found in ", name)

# ---------------------------
#   MOVEMENT METHODS
# ---------------------------
func start_pull(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	is_pulling = true
	pulling_direction = direction.normalized()

func stop_pull() -> void:
	is_pulling = false

func _physics_process(delta: float) -> void:
	if is_pulling:
		var motion := pulling_direction * pull_speed * delta
		_move_safe(motion)

func push(direction: Vector2, delta: float) -> void:
	var motion := direction.normalized() * push_strength * delta
	_move_safe(motion)

func _move_safe(motion: Vector2) -> void:
	velocity = motion / get_physics_process_delta_time()
	move_and_slide()
	rotation = 0
