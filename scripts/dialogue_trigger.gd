extends Area2D

@export var dialogue_file: String = "res://dialogue/minigame_1.dialogue"
@export var dialogue_start: String = "start"

var has_triggered: bool = false
var dialogue_resource: DialogueResource

func _ready():
	# Load the dialogue resource
	dialogue_resource = load(dialogue_file)
	if dialogue_resource:
		print("Dialogue resource loaded: ", dialogue_file)
	else:
		print("ERROR: Failed to load dialogue resource: ", dialogue_file)
		return
	
	body_entered.connect(_on_body_entered)
	call_deferred("_check_for_existing_bodies")

func _check_for_existing_bodies():
	if not dialogue_resource:
		return
		
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Tristan_gameplay" and not has_triggered:
			_start_dialogue()
			break

func _on_body_entered(body: Node2D):
	if not dialogue_resource:
		return
		
	if body.name == "Tristan_gameplay" and not has_triggered:
		_start_dialogue()

func _start_dialogue():
	if has_triggered or not dialogue_resource:
		return
		
	print("Starting dialogue...")
	has_triggered = true
	
	# Show the dialogue balloon
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	
	# Start minigame after a short delay (simpler than signal handling)
	await get_tree().create_timer(0.5).timeout
	_start_minigame()

func _start_minigame():
	var puzzle_manager = get_node("../PuzzleManager")
	if puzzle_manager and puzzle_manager.has_method("start_minigame"):
		puzzle_manager.start_minigame()
	else:
		print("PuzzleManager not found or missing start_minigame method")
