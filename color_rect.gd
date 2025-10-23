extends ColorRect

func set_brightness(value):
	self.color.a = clamp(1.0 - (value - 0.5) / 1.5, 0.0, 1.0)


func _on_h_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
