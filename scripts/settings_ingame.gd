# SimpleSettings.gd
extends Control

@onready var volume_slider = $Panel/VBoxContainer/Volume/HSlider
@onready var brightness_slider = $Panel/VBoxContainer/Brightness/HSlider
@onready var fullscreen_check = $Panel/VBoxContainer/Fullscreen/CheckBox
@onready var back_button = $Panel/VBoxContainer/BackButton

func _ready():
	load_current_settings()

func load_current_settings():
	volume_slider.value = Settings.master_volume
	brightness_slider.value = Settings.brightness
	fullscreen_check.button_pressed = Settings.fullscreen

func _on_volume_slider_value_changed(value: float):
	Settings.master_volume = value
	Settings.apply_settings()

func _on_brightness_slider_value_changed(value: float):
	Settings.brightness = value
	Settings.apply_settings()

func _on_fullscreen_check_toggled(toggled: bool):
	Settings.fullscreen = toggled
	Settings.apply_settings()

func _on_back_button_pressed():
	Settings.save_settings()
	queue_free()  # Remove settings menu
