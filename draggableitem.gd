extends Control  # This script is now attached to the Control node, not the Sprite2D

var is_dragging = false  # Track if dragging is in progress
var offset = Vector2.ZERO  # To store the offset from the mouse position
@onready var sprite: Sprite2D = $Sprite2D  # Reference to the Sprite2D node inside the Control

func _ready():
	sprite.visible = false  # Hide the sprite initially (until inventory is open)

func _input(event):
	# Mouse button event for dragging
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and sprite.get_rect().has_point(sprite.to_local(event.position)):
				# Start dragging when the mouse is clicked inside the sprite
				is_dragging = true
				offset = position - event.position  # Calculate the offset for dragging
				print("Started dragging the sprite!")

			elif not event.pressed:
				# Stop dragging when the mouse button is released
				is_dragging = false
				print("Stopped dragging the sprite at position: ", position)

	if is_dragging and event is InputEventMouseMotion:
		# Update the sprite's position as the mouse moves, considering the offset
		position = event.position + offset  # Apply the offset to position it correctly
		print("Dragging... Mouse Position: ", event.position, " Sprite Position: ", position)
