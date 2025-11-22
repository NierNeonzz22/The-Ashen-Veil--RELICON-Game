extends Node

@export var pillars: Array[NodePath] = []

signal puzzle_completed

func _ready():
	_connect_pillar_signals()
	print("Mirror Puzzle Ready - arrange pillars to form octagon!")

func _connect_pillar_signals():
	var connected_count = 0
	for path in pillars:
		var pillar = get_node_or_null(path)
		if pillar and not pillar.is_connected("lit_changed", Callable(self, "_on_pillar_lit_changed")):
			pillar.connect("lit_changed", Callable(self, "_on_pillar_lit_changed"))
			connected_count += 1
	
	print("Connected ", connected_count, "/", pillars.size(), " pillar signals")

func _on_pillar_lit_changed(_pillar):
	_check_all_lit()

func _check_all_lit():
	for path in pillars:
		var pillar = get_node_or_null(path)
		if pillar and not pillar.is_lit:
			return
	
	print("🎉 PUZZLE SOLVED! All pillars lit!")
	emit_signal("puzzle_completed")
