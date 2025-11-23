extends Panel  # Assuming root node of your inventory UI is a Panel

@export var character_body: CharacterBody2D  # Reference to CharacterBody2D script

func _ready():
	# Assuming CloseButton is a child of the root node (e.g., Panel)
	var close_button = $CloseButton  # Adjust the path if necessary
	close_button.connect("pressed", Callable(self, "_on_inventory_close"))

# Function to call when the close button is pressed
func _on_inventory_close():
	if character_body != null:
		character_body.close_inventory()  # Call the method in CharacterBody2D to close inventory
	queue_free()  # Optionally, remove the inventory UI scene
