# TimerUI.gd
extends Node2D

@onready var time_label: Label = $TimeLabel
@onready var background: AnimatedSprite2D = $Background
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var low_time_threshold: float = 10.0
@export var normal_color: Color = Color.WHITE
@export var low_color: Color = Color.RED

var is_ready: bool = false

func _ready():
	# Wait until we're properly in the scene tree
	if not is_inside_tree():
		await ready
	
	# Play the slide-down animation when the timer appears
	if animation_player and animation_player.has_animation("timer_slide_down"):
		animation_player.play("timer_slide_down")
	
	is_ready = true
	print("✅ TimerUI initialized successfully")

func update_time(time_remaining: float):
	# Safety check - only update if we're ready and in the scene tree
	if not is_ready or not is_inside_tree():
		return
	
	if not time_label:
		return
	
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	var time_text = "%02d:%02d" % [minutes, seconds]
	
	time_label.text = time_text
	
	# Visual effects for low time
	if time_remaining <= low_time_threshold:
		time_label.modulate = low_color
		# Add pulsing effect for low time (only if slide animation is done)
		if animation_player and not animation_player.is_playing():
			var tween = create_tween()
			tween.tween_property(time_label, "scale", Vector2(1.2, 1.2), 0.3)
			tween.tween_property(time_label, "scale", Vector2(1.0, 1.0), 0.3)
	else:
		time_label.modulate = normal_color
