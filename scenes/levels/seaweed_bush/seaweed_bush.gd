extends Node2D

@onready var anim = $Animate


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("idle")


func _on_area_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_is_hidden_from_enemies(true)


func _on_area_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		body.set_is_hidden_from_enemies(false)
