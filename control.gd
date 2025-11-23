extends Control

@onready var inventory_panel: Panel = $InventoryPanel
@onready var draggable_item_scene = preload("res://DraggableItem.tscn")

func _ready():
	# Example: Add draggable items to the inventory
	for i in range(3):
		var draggable_item_instance = draggable_item_scene.instantiate()
		# Set up the draggable item (texture, size, etc.)
		var sprite = draggable_item_instance.get_node("Sprite2D")  # Access Sprite2D
		sprite.texture = preload("res://Minigame Assets/Relicon_MULAWIN__A_-removebg-preview.png")
		
		# Add it to the inventory UI
		inventory_panel.add_child(draggable_item_instance)

		# Optionally connect any signals or logic
		draggable_item_instance.connect("dropped", Callable(self, "_on_item_dropped"))

# Handle when an item is dropped into the inventory
func _on_item_dropped(new_position: Vector2):
	print("Item dropped at position: ", new_position)
	# Handle item position update here (e.g., snapping to a grid or reordering)
