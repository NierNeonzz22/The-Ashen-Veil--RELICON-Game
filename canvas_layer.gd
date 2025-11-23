extends CanvasLayer

@onready var inventory_panel: Panel = $"/root/CanvasLayer/InventoryPanel"
@onready var grid_container: GridContainer = $"/root/CanvasLayer/InventoryPanel/GridContainer"
@onready var draggable_item_scene = preload("res://DraggableItem.tscn")

var items_in_order: Array = []  # List to track correct order

func _ready():
	# Add draggable items to the inventory
	for i in range(5):  # Example: 5 draggable items
		var draggable_item = draggable_item_scene.instantiate()
		var sprite = draggable_item.get_node("Sprite2D")
		sprite.texture = preload("res://Minigame Assets/Relicon_MULAWIN__A_-removebg-preview.png")
		
		# Add it to the GridContainer
		grid_container.add_child(draggable_item)
		
		# Optionally connect signals to check if the items are in the right order
		draggable_item.connect("dragged", Callable(self, "_on_item_dragged"))

# When an item is dragged, check if they are in the correct order
func _on_item_dragged():
	# Check the positions of the items in the GridContainer
	var correct_order = true
	var children = grid_container.get_children()
	
	# Example: Ensure they are in the right order (e.g., check grid positions)
	for i in range(children.size()):
		var item = children[i]
		if item.position.x != i * 50:  # Example condition to check position (adjust as needed)
			correct_order = false
			break
	
	# If the order is correct, trigger an action
	if correct_order:
		print("Items are in the correct order!")
		# Do something, like completing a puzzle or triggering an action
