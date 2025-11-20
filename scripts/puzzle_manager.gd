extends Node

@export var pillars: Array[NodePath] = []

signal puzzle_completed

func _ready():
	# Connect each pillar's signal
	for path in pillars:
		var pillar = get_node(path)
		if pillar:
			pillar.connect("lit_changed", Callable(self, "_on_pillar_lit_changed"))

func _on_pillar_lit_changed(_pillar):
	_check_all_lit()

func _check_all_lit():
	for path in pillars:
		var pillar = get_node(path)
		if pillar and not pillar.is_lit:
			return  # at least one not lit, puzzle incomplete
	# All lit
	print("Puzzle completed!")
	emit_signal("puzzle_completed")
