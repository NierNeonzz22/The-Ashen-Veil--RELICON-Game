extends Node2D

@export var octagon_radius: float = 200.0
@export var center_position: Vector2 = Vector2(640, 360)  # Adjust to your screen center

func _ready():
	arrange_pillars_in_octagon()

func arrange_pillars_in_octagon():
	var pillars = get_tree().get_nodes_in_group("pillar")
	
	if pillars.size() != 8:
		push_error("Need exactly 8 pillars for octagon arrangement")
		return
	
	# Arrange pillars in octagon formation (45 degrees apart)
	for i in range(8):
		var angle = i * (2 * PI / 8)  # 45 degrees in radians
		var x = center_position.x + octagon_radius * cos(angle)
		var y = center_position.y + octagon_radius * sin(angle)
		pillars[i].global_position = Vector2(x, y)
		
		# Optional: Add slight random offset to make puzzle more interesting
		# pillars[i].global_position += Vector2(randf_range(-10, 10), randf_range(-10, 10))
