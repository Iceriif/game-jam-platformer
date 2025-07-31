extends Area2D




func _on_body_entered(body):
	if body.is_in_group("player"):
		body.currentState = body.States.Stick
		body.forcedstate = true
		body.hasjump = 2


func _on_body_exited(body):
	if body.is_in_group("player"):
		body.forcedstate = false
		body.hasjump -= 1
