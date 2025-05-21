extends Node2D

var has_triggered := false
var explode_timer := Timer.new()
@onready var area_detection = $AreaDetection

var velocity: Vector2 = Vector2.ZERO
var move_target: Vector2 = Vector2.ZERO
var move_speed: float = 180.0 # You can adjust this speed
var moving: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Stunrock instance ready!")
	area_detection.body_entered.connect(_on_area_body_entered)
	explode_timer.wait_time = 0.1
	explode_timer.one_shot = true
	explode_timer.timeout.connect(_on_explode_timer_timeout)
	add_child(explode_timer)


# Called every frame.
func _physics_process(_delta: float) -> void:
	if moving:
		var to_target = move_target - global_position
		if to_target.length() < move_speed * _delta:
			global_position = move_target
			velocity = Vector2.ZERO
			moving = false
		else:
			velocity = to_target.normalized() * move_speed
			global_position += velocity * _delta


func set_move_target(target: Vector2):
	move_target = target
	moving = true


func _on_area_body_entered(_body):
	if not has_triggered:
		has_triggered = true
		explode_timer.start()


func _on_explode_timer_timeout():
	print("explode")
	for body in area_detection.get_overlapping_bodies():
		if body.has_method("stun"):
			body.stun()
	queue_free() # TEMP: comment out for debug
