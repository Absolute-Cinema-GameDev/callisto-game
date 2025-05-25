extends Node2D

@export var stunrock_scene: PackedScene
@export var min_spawn_interval: float = 3.0
@export var max_spawn_interval: float = 6.0

var _timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Spawner ready! stunrock_scene:", stunrock_scene)
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_timer)
	_schedule_next_spawn()

func _schedule_next_spawn():
	var wait_time = randf_range(min_spawn_interval, max_spawn_interval)
	_timer.start(wait_time)

func _on_spawn_timer_timeout():
	spawn_stunrocks_at_targets()
	_schedule_next_spawn()

func spawn_stunrocks_at_targets():
	if stunrock_scene == null:
		print("No stunrock scene assigned! (spawn_stunrocks_at_targets)")
		return
	# Spawn a random number of stunrocks (1 to 3)
	var num_stunrocks = randi() % 3 + 1
	for i in range(num_stunrocks):
		var target_pos = Vector2(randi() % 620 + 20, randi() % 300 + 20)
		var stunrock = stunrock_scene.instantiate()
		get_tree().current_scene.add_child(stunrock)
		stunrock.global_position = global_position
		if stunrock.has_method("set_move_target"):
			stunrock.set_move_target(target_pos)
		# Schedule stunrock to explode after 8 seconds
		var explode_timer = Timer.new()
		explode_timer.one_shot = true
		explode_timer.wait_time = 8.0
		explode_timer.timeout.connect(func():
			if is_instance_valid(stunrock):
				stunrock.explode()
		)
		stunrock.add_child(explode_timer)
		explode_timer.start()
		print("Spawned stunrock at", stunrock.global_position, "moving to", target_pos)
