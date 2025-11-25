extends Node2D  # Or Control if this is managing UI

@onready var inventory_panel: Panel = $"CanvasLayer/InventoryPanel"  # Inventory Panel
@onready var player: CharacterBody2D = $"CharacterBody2D"  # Path to the player node


var draggable_sprite_instance: Sprite2D = null  # To hold the instance of the draggable sprite
var is_inventory_open = false

func _ready():
	# Ensure the inventory panel starts hidden
	inventory_panel.visible = false

	# Create a new Sprite2D instance for the draggable sprite
	draggable_sprite_instance = Sprite2D.new()
	
	# Set the texture of the draggable sprite (resize it if needed)
	draggable_sprite_instance.texture = preload("res://Minigame Assets/Relicon_MULAWIN__A_-removebg-preview.png")
	draggable_sprite_instance.scale = Vector2(0.2, 0.2)  # Scale down the sprite if needed

	# Add the draggable sprite as a child of the inventory panel
	inventory_panel.add_child(draggable_sprite_instance)

	# Set the initial position of the draggable sprite inside the panel
	draggable_sprite_instance.position = Vector2(50, 50)  # Example position inside the panel
	draggable_sprite_instance.visible = false  # Hide it initially

func _process(delta):
	# Check if the "Inventory" key (E) is pressed
	if Input.is_action_just_pressed("inventory"):
		# Toggle the visibility of the Inventory Panel
		is_inventory_open = not is_inventory_open
		inventory_panel.visible = is_inventory_open
		
		# If the inventory panel is open, position it at the player's position
		if is_inventory_open:
			inventory_panel.position = player.global_position
			draggable_sprite_instance.visible = true  # Show the draggable sprite when the inventory is open
		else:
			draggable_sprite_instance.visible = false  # Hide the draggable sprite when the inventory is closed
