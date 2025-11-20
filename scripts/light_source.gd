extends Node2D

@export var pillar_nodes: Array[NodePath] = []
@export var max_bounces := 8
@export var beam_length := 2000.0
@export var beam_direction: Vector2 = Vector2.from_angle(deg_to_rad(-135))   # fixed beam direction
@export var beam_color: Color = Color(1, 0.9, 0.4)
@export var beam_width: float = 4.0

@onready var ray: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D

func _ready() -> void:
	ray.enabled = false
	line.clear_points()

func _process(_delta: float) -> void:
	_cast_and_draw_beam()

func _cast_and_draw_beam() -> void:
	line.clear_points()
	line.default_color = beam_color
	line.width = beam_width

	var origin_global: Vector2 = global_position
	var direction: Vector2 = beam_direction.normalized()

	# start visual line with the LightSource local origin
	line.add_point(Vector2.ZERO)

	for i in range(max_bounces):
		var to_point: Vector2 = origin_global + direction * beam_length

		# position and update the RayCast2D for this segment
		ray.global_position = origin_global
		ray.target_position = direction * beam_length
		ray.force_raycast_update()

		if not ray.is_colliding():
			# no collision -> draw to max distance and stop
			line.add_point(to_local(to_point))
			return

		# Explicitly typed results from RayCast2D
		var collision_point: Vector2 = ray.get_collision_point() as Vector2
		var collision_normal: Vector2 = ray.get_collision_normal() as Vector2
		var collider := ray.get_collider()  # type can be Object/Node

		# draw hit point
		line.add_point(to_local(collision_point))

		# If the collider is a pillar (must be added to group "pillar")
		if collider and (collider is Node) and (collider as Node).is_in_group("pillar"):
			# call the pillar's light_up method (safely)
			var pillar_node: Node = collider as Node
			if pillar_node.has_method("light_up"):
				pillar_node.call("light_up")

		# compute reflected direction and continue from slightly beyond the hit point
		direction = direction.bounce(collision_normal).normalized()
		origin_global = collision_point + direction * 1.0  # nudge forward to avoid re-hit
