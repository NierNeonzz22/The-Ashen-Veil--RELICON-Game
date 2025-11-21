extends Area2D

signal button_pressed(button_number: int)

@export var button_number: int = 1
@export var note_sound: AudioStream

@onready var normal_sprite = $NormalSprite
@onready var lit_sprite = $LitSprite
@onready var collision_shape = $CollisionShape2D
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	if note_sound and audio_player:
		audio_player.stream = note_sound
	
	input_event.connect(_on_input_event)
	set_lit(false)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			on_click()

func on_click():
	if collision_shape.disabled:
		return
	
	player_click_highlight()
	button_pressed.emit(button_number)

func player_click_highlight():
	set_lit(true)
	play_note()
	await get_tree().create_timer(0.3).timeout
	set_lit(false)

func highlight():
	set_lit(true)
	play_note()
	await get_tree().create_timer(0.5).timeout
	set_lit(false)

func play_note():
	if audio_player and note_sound:
		audio_player.play()

func set_lit(is_lit: bool):
	if normal_sprite:
		normal_sprite.visible = not is_lit
	if lit_sprite:
		lit_sprite.visible = is_lit

func set_disabled(disabled: bool):
	collision_shape.disabled = disabled
	if disabled:
		if normal_sprite: normal_sprite.modulate = Color.GRAY
		if lit_sprite: lit_sprite.modulate = Color.GRAY
	else:
		if normal_sprite: normal_sprite.modulate = Color.WHITE
		if lit_sprite: lit_sprite.modulate = Color.WHITE
