extends HSlider

@export var audio_bus_name: String = "Master"  # or "Music" if you have sub-buses
var audio_bus_id: int

func _ready():
	# Find which audio bus to control
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	
	# Connect the value_changed signal
	connect("value_changed", Callable(self, "_on_value_changed"))
	
	# Apply the current volume at start
	_on_value_changed(value)

func _on_value_changed(value: float) -> void:
	# Convert slider's 0–1 value to decibels
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)


func _on_brightness_value_changed(value: float) -> void:
	pass # Replace with function body.
