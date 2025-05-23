extends Area2D

@export var suction_force: float = 150.0
@export var stunrock_suction_force: float = 100.0  # Can be different than player force
@export var suction_active: bool = true  # Toggle to enable/disable suction

var bodies_in_area: Array = []
var stunrocks_in_area: Array = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# For areas, we need to use area signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_body_entered(body) -> void:
	if body is Player:
		bodies_in_area.append(body)

func _on_body_exited(body) -> void:
	if body in bodies_in_area:
		bodies_in_area.erase(body)

func _on_area_entered(area) -> void:
	# Check if it's a stunrock
	if area.get_parent() is Node2D and area.get_parent().get_script() and area.get_parent().get_script().resource_path.ends_with("stunrock.gd"):
		stunrocks_in_area.append(area.get_parent())

func _on_area_exited(area) -> void:
	if area.get_parent() in stunrocks_in_area:
		stunrocks_in_area.erase(area.get_parent())

func _physics_process(delta: float) -> void:
	if not suction_active:
		return
		
	# Apply suction to players
	for body in bodies_in_area:
		if body is Player:
			body.velocity += Vector2(-suction_force, 0) * delta
	
	# Apply suction to stunrocks
	for stunrock in stunrocks_in_area:
		if stunrock.has_method("_physics_process"):
			# If the stunrock is currently moving to a target, override its target
			stunrock.global_position.x -= stunrock_suction_force * delta
