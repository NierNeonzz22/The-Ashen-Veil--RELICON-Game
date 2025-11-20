extends Node

@onready var brightness_overlay = $ColorRect
@onready var slider = $HSlider

func _ready():
	# Initialize brightness when the scene starts
	brightness_overlay.color.a = clamp(1.0 - (slider.value - 0.5) / 1.5, 0.0, 1.0)

func _on_h_slider_value_changed(value):
	# Adjust brightness overlay transparency
	brightness_overlay.color.a = clamp(1.0 - (value - 0.5) / 1.5, 0.0, 1.0)
