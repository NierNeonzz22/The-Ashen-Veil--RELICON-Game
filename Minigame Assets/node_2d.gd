extends Node2D

@export var radius: float = 50  # Set dynamically from player

func _draw():
	# Draw filled circle
	draw_circle(Vector2.ZERO, radius, Color(0, 1, 0, 0.2))
	# Draw outline
	draw_circle(Vector2.ZERO, radius, Color(0, 1, 0, 0.5))

func _process(_delta):
	global_position = get_parent().global_position
	
