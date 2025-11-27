extends Node2D

@export var label_instruction_scene: PackedScene

func _ready():
	print("Map scene ready - starting label spawn process")
	# Wait a bit longer to ensure player is loaded
	await get_tree().create_timer(1.0).timeout
	spawn_instruction_label()

func spawn_instruction_label():
	print("=== SPAWN INSTRUCTION LABEL STARTED ===")
	
	if not label_instruction_scene:
		push_error("Label instruction scene not assigned in Inspector!")
		return
	else:
		print("✓ Label instruction scene is assigned")

	# Search for the player by exact name "Player"
	var player = get_tree().root.get_node("Player")
	
	if not player:
		# Try searching recursively through the entire scene tree
		print("Searching recursively for node named 'Player'...")
		player = find_node_by_name(get_tree().root, "Player")
	
	if not player:
		push_error("❌ Player node not found!")
		# Print all nodes to help debug
		print_all_nodes(get_tree().root)
		return
	else:
		print("✓ Player found: ", player.name)
		print("✓ Player type: ", player.get_class())

	# Find the camera on the player
	var camera = null
	if player.has_node("Camera2D"):
		camera = player.get_node("Camera2D")
		print("✓ Found Camera2D as direct child of player")
	else:
		# Search for Camera2D in player's children
		print("Searching for Camera2D in player children...")
		for child in player.get_children():
			print("  - Child: ", child.name, " (", child.get_class(), ")")
			if child is Camera2D:
				camera = child
				print("✓ Found Camera2D: ", camera.name)
				break
		
		# If still not found, search recursively
		if not camera:
			camera = find_camera_in_children(player)
	
	if not camera:
		push_error("❌ Camera2D not found on player!")
		return
	else:
		print("✓ Camera found: ", camera.name)

	# Instantiate the label
	print("Instantiating label...")
	var label_instance = label_instruction_scene.instantiate()
	
	# Set properties using the methods
	if label_instance.has_method("set_instruction_text"):
		label_instance.set_instruction_text("Explore the area and go to the beach!")
		print("✓ Text set successfully")
	else:
		push_error("❌ set_instruction_text method not found!")
		return
		
	if label_instance.has_method("set_display_time"):
		label_instance.set_display_time(20.0)
		print("✓ Display time set to 20 seconds")
	
	# Add to camera
	print("Adding label to camera...")
	camera.add_child(label_instance)
	label_instance.position = Vector2(250, 130)
	print("✓ Instruction label added to camera!")
	print("=== SPAWN INSTRUCTION LABEL COMPLETED ===")

# Helper function to find node by exact name
func find_node_by_name(root: Node, node_name: String) -> Node:
	if root.name == node_name:
		return root
	
	for child in root.get_children():
		var found = find_node_by_name(child, node_name)
		if found:
			return found
	
	return null

# Helper function to find camera in children
func find_camera_in_children(node: Node) -> Camera2D:
	for child in node.get_children():
		if child is Camera2D:
			return child
		# Recursively search deeper
		var found = find_camera_in_children(child)
		if found:
			return found
	return null

# Debug function to print all nodes
func print_all_nodes(root: Node, indent: String = ""):
	print(indent + root.name + " (" + root.get_class() + ")")
	for child in root.get_children():
		print_all_nodes(child, indent + "  ")
