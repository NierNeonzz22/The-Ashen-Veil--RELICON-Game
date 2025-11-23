extends Control

var lines = [
	"Pablo",
	"Elia",
	"Pablo",
	"Elia (sighs).",
	"Elia",
	"Pablo",
	"Elia",
	"Pablo",
]

var index := 0
var typing := false
var type_speed := 0.01

func _ready():
	$TextLabel1.bbcode_enabled = true

	# ADD THIS DELAY BEFORE SHOWING FIRST LINE
	await get_tree().create_timer(1.0).timeout
	
	show_line()


func show_line():
	typing = true
	$TextLabel1.visible_characters = 0
	$TextLabel1.text = lines[index]

	# TYPEWRITER START DELAY (your existing 0.2s)
	await get_tree().create_timer(0.2).timeout
	type_line()


func type_line():
	while $TextLabel1.visible_characters < $TextLabel1.text.length():
		$TextLabel1.visible_characters += 1
		await get_tree().create_timer(type_speed).timeout
	typing = false


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if typing:
			# INSTANT FINISH
			$TextLabel1.visible_characters = $TextLabel1.text.length()
			typing = false
		else:
			# NEXT LINE
			index += 1
			if index < lines.size():
				show_line()
			else:
				queue_free()
