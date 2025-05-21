extends Node2D

@export var stunrock_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Spawner ready! stunrock_scene:", stunrock_scene)
	call_deferred("spawn_stunrocks_at_targets")

func spawn_stunrocks_at_targets():
	if stunrock_scene == null:
		print("No stunrock scene assigned! (spawn_stunrocks_at_targets)")
		return
	for i in range(3):
		var target_pos = Vector2(randi() % 640, randi() % 320)
		var stunrock = stunrock_scene.instantiate()
		get_tree().current_scene.add_child(stunrock)
		stunrock.global_position = global_position
		if stunrock.has_method("set_move_target"):
			stunrock.set_move_target(target_pos)
		print("Spawned stunrock at", stunrock.global_position, "moving to", target_pos)
