extends Sprite2D

# Store the original position and a flag for dragging
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Signal for when the item is dropped
signal dropped(new_position)

func _ready():
	# Set up initial conditions for the draggable item (if needed)
	pass

func _input(event):
	# Only respond to mouse button events (left click)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# When mouse button is pressed, start dragging
				if get_rect().has_point(to_local(event.position)):
					is_dragging = true
					drag_offset = global_position - event.position
			else:
				# When mouse button is released, stop dragging
				if is_dragging:
					is_dragging = false
					emit_signal("dropped", global_position)  # Emit the signal when dropped
				
	# While dragging, update the item's position
	if is_dragging:
		global_position = event.position + drag_offset
