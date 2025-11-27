extends AudioStreamPlayer2D

func _ready() -> void:
	# Just play the audio - no loop settings
	play()
	print("Background music started")
