extends Node2D

@onready var inventory_panel: ColorRect = $"ColorRect" 

@onready var draggable_objects: Array = [
	$"Sprite2D2", $"Sprite2D3", $"Sprite2D4",
	$"Sprite2D5", $"Sprite2D6", $"Sprite2D7", $"Sprite2D8"
]

# Reset positions
@onready var reset_positions := {
	"Sprite2D2": Vector2(150, 50),
	"Sprite2D3": Vector2(250, 50),
	"Sprite2D4": Vector2(350, 50),
	"Sprite2D5": Vector2(450, 50),
	"Sprite2D6": Vector2(550, 50),
	"Sprite2D7": Vector2(650, 50),
	"Sprite2D8": Vector2(750, 50)
}

# Slots
@onready var slots: Array = [
	$"Node2D2/Slot1",
	$"Node2D2/Slot2",
	$"Node2D2/Slot3",
	$"Node2D2/Slot4",
	$"Node2D2/Slot5",
	$"Node2D2/Slot6",
	$"Node2D2/Slot7"
]

# SLOT → correct sprite mapping
var slot_targets := {
	"Slot1": "Sprite2D7",
	"Slot2": "Sprite2D5",
	"Slot3": "Sprite2D8",
	"Slot4": "Sprite2D2",
	"Slot5": "Sprite2D4",
	"Slot6": "Sprite2D3",
	"Slot7": "Sprite2D6"
}

# ROCK → unlocks which sprite
var unlocks := {
	"Rock1": "Sprite2D7",
	"Rock2": "Sprite2D5",
	"Rock3": "Sprite2D8",
	"Rock4": "Sprite2D2",
	"Rock5": "Sprite2D4",
	"Rock6": "Sprite2D3",
	"Rock7": "Sprite2D6"
}

# tracks items unlocked by rocks
var unlocked_items := {}

var selected_sprite: Sprite2D = null
var mouse_offset: Vector2 = Vector2.ZERO
var is_inventory_open := false



###############################
# INITIAL SETUP
###############################
func _ready():
	inventory_panel.visible = false
	
	for obj in draggable_objects:
		obj.visible = false  # invisible until unlocked

	for slot in slots:
		slot.visible = false
		var highlight = slot.get_node("Highlight")
		highlight.color = Color(1, 0, 0, 0.4)

	$"ColorRect/ResetButton".visible = false
	$"ColorRect/ResetButton".pressed.connect(_on_reset_pressed)



###############################
# MAIN UPDATE LOOP
###############################
func _process(delta):
	if Input.is_action_just_pressed("Inventory"):
		toggle_inventory()

	if selected_sprite:
		selected_sprite.position = get_global_mouse_position() + mouse_offset



###############################
# INVENTORY TOGGLE
###############################
func toggle_inventory():
	is_inventory_open = !is_inventory_open
	inventory_panel.visible = is_inventory_open
	$"ColorRect/ResetButton".visible = is_inventory_open

	update_inventory_visibility()



###############################
# UPDATE WHAT IS VISIBLE
###############################
func update_inventory_visibility():
	for obj in draggable_objects:
		obj.visible = is_inventory_open and unlocked_items.has(obj.name)

	for slot in slots:
		slot.visible = is_inventory_open



###############################
# ROCK BREAK → UNLOCK ITEM
###############################
func unlock_item_for_rock(rock_name: String):
	if unlocks.has(rock_name):
		var sprite_name = unlocks[rock_name]
		unlocked_items[sprite_name] = true
		print("Unlocked item: ", sprite_name)

		update_inventory_visibility()  # <--- important



###############################
# DRAGGING SYSTEM
###############################
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			for sprite in draggable_objects:
				if sprite.visible and sprite.get_rect().has_point(sprite.to_local(get_global_mouse_position())):
					selected_sprite = sprite
					mouse_offset = selected_sprite.position - get_global_mouse_position()
					break

		else:
			end_drag()



###############################
# DROP INTO SLOT / SNAP LOGIC
###############################
func end_drag():
	if selected_sprite == null:
		return

	for slot in slots:
		if sprite_over_slot(selected_sprite, slot):

			# Snap into slot
			selected_sprite.global_position = slot.global_position

			# verify correctness
			var required_name = slot_targets.get(slot.name, "")
			var highlight = slot.get_node("Highlight")

			if selected_sprite.name == required_name:
				highlight.color = Color(0, 1, 0, 0.5)  # correct → green
			else:
				highlight.color = Color(1, 0, 0, 0.5)  # wrong → red

			break

	selected_sprite = null



###############################
# SLOT COLLISION CHECK
###############################
func sprite_over_slot(sprite: Sprite2D, slot: Area2D) -> bool:
	var shape := slot.get_node("CollisionShape2D").shape as RectangleShape2D
	var half: Vector2 = shape.extents

	var forgiveness := 40  # easier to drop inside

	var slot_rect := Rect2(
		slot.global_position - half - Vector2(forgiveness, forgiveness),
		(half * 2) + Vector2(forgiveness * 2, forgiveness * 2)
	)

	return slot_rect.has_point(sprite.global_position)



###############################
# RESET BUTTON
###############################
func _on_reset_pressed():
	for obj in draggable_objects:
		if reset_positions.has(obj.name):
			obj.global_position = reset_positions[obj.name]

	for slot in slots:
		slot.get_node("Highlight").color = Color(1, 0, 0, 0.4)
		
