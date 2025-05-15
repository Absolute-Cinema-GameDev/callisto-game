extends Area2D

# Called when a body enters the air pocket
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_is_in_airpocket(true)

# Called when a body exits the air pocket
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.set_is_in_airpocket(false)
