extends Node2D

@export var instruction_text: String = "Arrange the pillars to form \nan octagon light pattern! \nPush pillars using WASD keys\nPress E to pull"
@export var custom_font: FontFile  # Drag your custom font here in Inspector
@export var font_size: int = 11
@export var text_color: Color = Color.SADDLE_BROWN
@export var display_duration: float = 5.0  # How long to show the instructions

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var background_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label

func _ready():
	# Play slide animation if available
	if animation_player and animation_player.has_animation("slide left"):
		animation_player.play("slide left")
	
	# Set up the label
	label.text = instruction_text
	
	# Enable auto-wrap and center alignment for better appearance
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	if custom_font:
		label.add_theme_font_override("font", custom_font)
	
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	
	# Start background animation if available
	if background_sprite and background_sprite.sprite_frames:
		background_sprite.play()
	
	# Auto-hide after duration
	if display_duration > 0:
		await get_tree().create_timer(display_duration).timeout
		queue_free()

# Manual control functions
func show_instructions():
	visible = true
	if background_sprite and background_sprite.sprite_frames:
		background_sprite.play()

func hide_instructions():
	visible = false
	if background_sprite:
		background_sprite.stop()

func set_instruction_text(new_text: String):
	instruction_text = new_text
	if label:
		label.text = new_text

func set_display_time(seconds: float):
	display_duration = seconds
