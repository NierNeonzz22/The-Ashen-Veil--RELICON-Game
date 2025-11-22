extends Node2D

@export var max_bounces := 11
@export var beam_length := 2000.0
@export var beam_direction: Vector2 = Vector2.LEFT.rotated(deg_to_rad(45))
@export var beam_color: Color = Color(1, 0.9, 0.4)
@export var beam_width: float = 4.0

@onready var ray: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D

var hit_pillars_this_frame: Array[Node] = []
var all_pillars: Array[Node] = []

func _ready() -> void:
	call_deferred("_initialize")

func _initialize():
	global_position = Vector2(527, 620)
	
	if ray:
		ray.enabled = true
		ray.collision_mask = 0xFFFF
		ray.collide_with_areas = true
		ray.collide_with_bodies = true
	
	if line:
		line.clear_points()
	
	_setup_pillars()

func _setup_pillars():
	all_pillars = get_tree().get_nodes_in_group("pillar")
	print("LightSource: Found ", all_pillars.size(), " pillars")

func _process(_delta: float) -> void:
	if not is_instance_valid(ray) or not is_instance_valid(line):
		return
		
	_unlight_missed_pillars()
	_cast_and_draw_beam()

func _unlight_missed_pillars():
	for pillar in all_pillars:
		if is_instance_valid(pillar) and pillar.has_method("unlight") and pillar not in hit_pillars_this_frame:
			pillar.unlight()
	hit_pillars_this_frame.clear()

func _cast_and_draw_beam() -> void:
	line.clear_points()
	line.default_color = beam_color
	line.width = beam_width

	var current_position: Vector2 = global_position
	var current_direction: Vector2 = beam_direction.normalized()

	line.add_point(Vector2.ZERO)  # Local origin

	for i in range(max_bounces):
		# Set up ray for this segment
		ray.global_position = current_position
		ray.target_position = current_direction * beam_length
		ray.force_raycast_update()

		if not ray.is_colliding():
			# No collision - draw to end point
			var end_point = current_position + current_direction * beam_length
			line.add_point(to_local(end_point))
			return

		var collision_point: Vector2 = ray.get_collision_point()
		var collider = ray.get_collider()

		# Draw to collision point
		line.add_point(to_local(collision_point))

		if collider and collider.is_in_group("pillar"):
			# Light up the pillar
			if is_instance_valid(collider) and collider.has_method("light_up"):
				collider.light_up()
				if not hit_pillars_this_frame.has(collider):
					hit_pillars_this_frame.append(collider)
			
			# Get redirect direction from pillar's fixed angle
			current_direction = Vector2.from_angle(deg_to_rad(collider.redirect_angle))
			
			# Move position to slightly beyond collision point to avoid re-hitting same pillar
			current_position = collision_point + current_direction * 10.0
			
		else:
			# Wall reflection
			var collision_normal: Vector2 = ray.get_collision_normal()
			current_direction = current_direction.bounce(collision_normal).normalized()
			current_position = collision_point + current_direction * 2.0
