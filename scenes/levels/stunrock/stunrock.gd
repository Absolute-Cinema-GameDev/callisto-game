extends Node2D

var has_triggered := false
var explode_timer := Timer.new()
@onready var area_detection = $AreaDetection


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_detection.body_entered.connect(_on_area_body_entered)
	explode_timer.wait_time = 0.1
	explode_timer.one_shot = true
	explode_timer.timeout.connect(_on_explode_timer_timeout)
	add_child(explode_timer)


# Called every frame.
func _process(_delta: float) -> void:
	pass


func _on_area_body_entered(_body):
	if not has_triggered:
		has_triggered = true
		explode_timer.start()


func _on_explode_timer_timeout():
	print("explode")
	for body in area_detection.get_overlapping_bodies():
		if body.has_method("stun"):
			body.stun()
	queue_free()
