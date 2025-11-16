extends Control

@onready var fade_layer: ColorRect = $FadeLayer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var start_button: Button = $UI/StartButton   # adjust if different path

func _ready() -> void:
	fade_layer.modulate.a = 0.0
	fade_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_start_button_pressed() -> void:
	print("Start button pressed!")  # ✅ test line
	start_button.disabled = true
	fade_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	anim.play("fade_out")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://scripts/scene_1_festival_scene.gd")
