extends HSlider

@onready var brightness_overlay = $"../ColorRect"  # Adjust path if needed

func _ready():
	# Start with normal brightness
	self.value = 1.0
	
	# Connect the signal
	connect("value_changed", Callable(self, "_on_value_changed"))
	
	# Apply current value on start
	_on_value_changed(value)

func _on_value_changed(value: float) -> void:
	if brightness_overlay:
		# Adjust transparency to simulate brightness
		brightness_overlay.color.a = clamp(1.0 - (value - 0.5) / 1.5, 0.0, 1.0)
	else:
		push_warning("Brightness overlay not found! Check node path.")
