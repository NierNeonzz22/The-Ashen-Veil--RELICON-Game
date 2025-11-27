# Settings.gd
extends Node

var master_volume: float = 1.0
var brightness: float = 1.0
var fullscreen: bool = false

func _ready():
	load_settings()

func save_settings():
	var config = {
		"master_volume": master_volume,
		"brightness": brightness,
		"fullscreen": fullscreen
	}
	
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	if file:
		file.store_var(config)
		file.close()

func load_settings():
	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		if file:
			var config = file.get_var()
			file.close()
			
			master_volume = config.get("master_volume", 1.0)
			brightness = config.get("brightness", 1.0)
			fullscreen = config.get("fullscreen", false)
			apply_settings()

func apply_settings():
	# Apply volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	
	# Apply fullscreen
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED
