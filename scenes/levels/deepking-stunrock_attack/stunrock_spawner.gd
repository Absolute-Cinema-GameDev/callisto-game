extends Node2D

@export var stunrock_scene: PackedScene

# Helper class for flying stun rock
class FlyingStunrock:
	var node: Node2D
	var velocity: Vector2
	var target: Vector2
	var speed: float = 400.0
	func _init(node, target, speed=400.0):
		self.node = node
		self.target = target
		self.speed = speed
		self.velocity = (target - node.global_position).normalized() * speed

var flying_stunrocks: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	launch_stunrocks()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for fs in flying_stunrocks:
		if fs.node and fs.node.is_inside_tree():
			move_flying_stunrock(fs, delta)
	# Remove finished stunrocks
	flying_stunrocks = flying_stunrocks.filter(func(fs): return fs.node and fs.node.is_inside_tree())

func move_flying_stunrock(fs, delta):
	var prev_pos = fs.node.global_position
	var to_target = fs.target - prev_pos
	if to_target.length() < fs.speed * delta:
		fs.node.global_position = fs.target
		return
	fs.node.global_position += fs.velocity * delta

func launch_stunrocks():
	if stunrock_scene == null:
		print("No stunrock scene assigned!")
		return
	for i in range(3):
		var target_pos = Vector2(randi() % 640, randi() % 320)
		var stunrock = stunrock_scene.instantiate()
		get_tree().current_scene.add_child(stunrock)
		# Always start at spawner's position
		stunrock.global_position = global_position
		stunrock.scale = Vector2(0.5, 0.5)
		if stunrock.has_node("Animate"):
			stunrock.get_node("Animate").modulate = Color(1,0,0)
		# Calculate velocity from spawner to target
		var fs = FlyingStunrock.new(stunrock, target_pos)
		fs.velocity = (target_pos - global_position).normalized() * fs.speed
		flying_stunrocks.append(fs)
		print("Spawned stunrock at", stunrock.global_position, "target:", target_pos)
