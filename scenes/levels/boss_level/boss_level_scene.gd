extends Node2D

enum AttackPattern { SINGLE, SEQUENTIAL, SIMULTANEOUS }

@export var tentacle_scene: PackedScene
@export var attack_positions: Array[NodePath] = []
@export var attack_cooldown: float = 2.0
@export var attack_interval: float = 0.5  # For sequential attacks
@export var damage: int = 10
@export var active: bool = true

var position_nodes: Array = []
var current_tentacles: Array = []
var can_attack: bool = true
var is_attacking: bool = false

func _ready() -> void:
	# Get position nodes from paths
	for path in attack_positions:
		var node = get_node(path)
		if node:
			position_nodes.append(node)
	
	# Start attack loop if active
	if active:
		attack_loop()

func _process(_delta: float) -> void:
	# Optional: Add visual indicators for attack positions during debugging
	pass

func attack_loop() -> void:
	while active:
		if can_attack and not is_attacking:
			perform_random_attack()
		await get_tree().process_frame

func perform_random_attack() -> void:
	if position_nodes.is_empty():
		print("No attack positions defined!")
		return
	
	# Choose a random attack pattern
	var pattern = randi() % AttackPattern.size()
	var num_tentacles = randi() % 3 + 1  # Random 1-3 tentacles
	
	# Get random attack positions
	var positions = position_nodes.duplicate()
	positions.shuffle()
	positions = positions.slice(0, min(num_tentacles, positions.size() - 1))
	
	# Start the attack sequence
	match pattern:
		AttackPattern.SINGLE:
			# Just attack with one tentacle
			spawn_and_attack_with_tentacle(positions[0].global_position)
		
		AttackPattern.SEQUENTIAL:
			# Attack with multiple tentacles in sequence
			start_sequential_attack(positions)
		
		AttackPattern.SIMULTANEOUS:
			# Attack with multiple tentacles at once
			start_simultaneous_attack(positions)

func spawn_tentacle() -> Node:
	var tentacle = tentacle_scene.instantiate()
	add_child(tentacle)
	
	# Configure the tentacle
	tentacle.attack_damage = damage
	
	# Connect signals
	tentacle.attack_finished.connect(_on_tentacle_attack_finished.bind(tentacle))
	
	# Add to tracking array
	current_tentacles.append(tentacle)
	return tentacle

func spawn_and_attack_with_tentacle(position: Vector2) -> void:
	var tentacle = spawn_tentacle()
	
	# Start the attack
	tentacle.start_attack(position)
	
	# Update states
	is_attacking = true
	can_attack = false

func start_sequential_attack(positions: Array) -> void:
	is_attacking = true
	can_attack = false
	
	for pos in positions:
		spawn_and_attack_with_tentacle(pos.global_position)
		await get_tree().create_timer(attack_interval).timeout

func start_simultaneous_attack(positions: Array) -> void:
	is_attacking = true
	can_attack = false
	
	for pos in positions:
		spawn_and_attack_with_tentacle(pos.global_position)

func _on_tentacle_attack_finished(tentacle) -> void:
	# Remove tentacle from tracking array
	current_tentacles.erase(tentacle)
	
	# Queue free the tentacle
	tentacle.queue_free()
	
	# If no more tentacles, attack is done
	if current_tentacles.is_empty():
		is_attacking = false
		
		# Start cooldown
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

# Public methods for other scripts to control the manager
func start_attacks() -> void:
	active = true
	attack_loop()

func stop_attacks() -> void:
	active = false
