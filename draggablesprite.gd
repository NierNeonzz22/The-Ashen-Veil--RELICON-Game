extends Sprite2D

var is_dragging = false  # To track if the sprite is being dragged
var drag_offset = Vector2.ZERO  # Offset from the mouse pointer to the sprite position

func _ready():
	visible = false  # Initially hide the sprite
	print("Draggable Sprite Ready!")

func _input(event):
	if event is InputEventMouseButton:
		print("Mouse Button Event Detected")
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("Mouse Pressed")
				var local_position = to_local(event.position)  # Get position relative to sprite
				print("Mouse Position Relative to Sprite: ", local_position)

				if get_rect().has_point(local_position):  # Check if clicked inside the sprite's area
					print("Clicked inside sprite!")
					is_dragging = true
					drag_offset = position - event.position  # Calculate offset relative to the sprite position
			elif not event.pressed and is_dragging:
				print("Mouse Released")
				is_dragging = false
				print("Stopped dragging the sprite at position: ", position)

	if is_dragging and event is InputEventMouseMotion:
		# Update the sprite position to follow the mouse pointer, applying the drag offset correctly
		print("Dragging... Mouse Position: ", event.position)
		position = to_local(event.position) + drag_offset  # Correctly update the sprite's position
		print("Sprite Position: ", position)  # Print the updated position
