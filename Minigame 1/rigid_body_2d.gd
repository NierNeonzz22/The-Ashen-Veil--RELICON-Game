extends RigidBody2D

signal lit_changed(pillar)

@export var sprite_unlit: Texture2D
@export var sprite_lit: Texture2D
@export var grid_step := 32
@export var pull_speed := 50.0
@export var is_lit := false

var pulling_direction := Vector2.ZERO
var is_pulling := false

func _ready():
	_update_visual()

	# Enable custom physics integration
	custom_integrator = true
	# Set angular velocity to zero
	angular_velocity = 0

func start_pull(direction: Vector2):
	if direction == Vector2.ZERO:
		return
	
	pulling_direction = direction.normalized()
	is_pulling = true

	# Switch to kinematic for manual movement
	PhysicsServer2D.body_set_mode(get_rid(), PhysicsServer2D.BODY_MODE_KINEMATIC)

func stop_pull():
	is_pulling = false
	_restore_rigid()

func _physics_process(delta):
	if is_pulling:
		var target: Vector2 = global_position + pulling_direction * pull_speed * delta

		var params := PhysicsPointQueryParameters2D.new()
		params.position = target
		params.collide_with_bodies = true
		params.collide_with_areas = false
		params.exclude = [self.get_rid()]

		var space = get_world_2d().direct_space_state
		if space.intersect_point(params).size() > 0:
			stop_pull()
			return
		
		global_position = target

func _restore_rigid():
	PhysicsServer2D.body_set_mode(get_rid(), PhysicsServer2D.BODY_MODE_RIGID)

# ------------------------------------
# LIGHT SYSTEM
# ------------------------------------

func light_up():
	if not is_lit:
		is_lit = true
		_update_visual()
		emit_signal("lit_changed", self)

func unlight():
	if is_lit:
		is_lit = false
		_update_visual()
		emit_signal("lit_changed", self)

func _update_visual():
	if is_lit:
		$Sprite2D.texture = sprite_lit
	else:
		$Sprite2D.texture = sprite_unlit
