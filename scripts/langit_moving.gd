# Animation for Langit movement

extends Sprite2D

@export var scroll_speed: float = 25.0  # pixels per second
var start_x: float
var end_x: float

func _ready():
	start_x = position.x
	end_x = texture.get_width() - get_viewport_rect().size.x

func _process(delta):
	position.x += scroll_speed * delta

	# When the background reaches the end, loop back
	if position.x > end_x or position.x < start_x:
		scroll_speed = -scroll_speed  # reverse direction
