extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	body_entered.connect(_on_body_entered)
	start_appearance_effect()

func start_appearance_effect():
	# Start invisible
	sprite.modulate.a = 0
	sprite.scale = Vector2(0.8, 0.8)
	
	# Enable looping for continuous animations
	if animation_player.has_animation("sparkle_animation"):
		var anim = animation_player.get_animation("sparkle_animation")
		anim.loop_mode = Animation.LOOP_LINEAR  # Enable looping
	
	# Play fade in animation
	if animation_player.has_animation("fade_in"):
		animation_player.play("fade_in")
		await animation_player.animation_finished
	
	# Start continuous animations (they'll now loop forever)
	if animation_player.has_animation("sparkle_animation"):
		animation_player.play("sparkle_animation")

func _on_body_entered(body):
	if body.name == "Tristan_gameplay":
		print("Gem collected!")
		collect_effect()

func collect_effect():
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
