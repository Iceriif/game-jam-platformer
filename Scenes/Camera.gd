extends Camera2D


# Optional: Smooth camera shake system
var shake_strength : int = 0

func _process(delta):
	if shake_strength > 0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = lerp(shake_strength, 0, delta * 5)
	else:
		offset = Vector2.ZERO

func shake(amount = 5.0):
	shake_strength = amount
