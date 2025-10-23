extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings: Panel = $Settings


func _process(delta: float) :
	pass

func _ready():
	main_buttons.visible = true 
	settings.visible = false

func _on_start_pressed() :
	print("Start pressed")


func _on_settings_2_pressed():
	print("Settings pressed")
	main_buttons.visible = false
	settings.visible = true 

func _on_exit_3_pressed():
	print("Exit pressed")


func _on_back_settings_pressed() -> void:
	_ready ()
	

@onready var settings_panel = $SettingsPanel

func _on_SettingsButton_pressed():
	settings_panel.visible = true

func _on_BackButton_pressed():
	settings_panel.visible = false
