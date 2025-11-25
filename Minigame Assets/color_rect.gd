extends ColorRect

func _ready():
	# Set initial color (for example, red with full transparency)
	self.color = Color(0, 0, 0, 0.6)  # Red color with 0 alpha (fully transparent)
	
func change_transparency(new_alpha: float):
	# Set the alpha component of the color to the new value
	self.color.a = new_alpha  # Alpha is between 0 (fully transparent) and 1 (fully opaque)
