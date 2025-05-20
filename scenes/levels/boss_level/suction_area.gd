extends Area2D

@export var suction_force: float = 150.0
var bodies_in_area: Array = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body) -> void:
	if body is Player:
		bodies_in_area.append(body)


func _on_body_exited(body) -> void:
	if body in bodies_in_area:
		bodies_in_area.erase(body)


func _physics_process(delta: float) -> void:
	for body in bodies_in_area:
		if body is Player:
			body.velocity += Vector2(-suction_force, 0) * delta
