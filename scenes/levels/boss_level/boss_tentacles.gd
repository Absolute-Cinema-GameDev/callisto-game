extends Node2D
# Export variables (properties)
@export var min_attack_interval: float = 2.0
@export var max_attack_interval: float = 4.0
@export var attack_duration: float = 1.5
@export var telegraph_duration: float = 2.0
@export var attack_pattern_chance: float = 0.3
@export var normal_color: Color = Color.WHITE
@export var telegraph_color: Color = Color(1.0, 0.5, 0.5, 0.7)
# Class member variables
var _timer: Timer
var _current_attack_indices = []
# Onready variables
@onready var tentacles = [$Tentacle, $Tentacle2, $Tentacle3]


func _ready():
	# Setup all tentacles as inactive initially
	for tentacle in tentacles:
		disable_tentacle(tentacle)
	# Create timer for attack pattern
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(_timer)
	# Start the attack cycle
	_schedule_next_attack()


func _schedule_next_attack():
	var wait_time = randf_range(min_attack_interval, max_attack_interval)
	_timer.start(wait_time)


func _on_attack_timer_timeout():
	# Decide on attack pattern (1 or 2 tentacles)
	var num_tentacles_to_attack = 2 if randf() < attack_pattern_chance else 1
	# Select which tentacles to use
	_current_attack_indices = []
	var available_indices = range(tentacles.size())
	available_indices.shuffle()
	for i in range(num_tentacles_to_attack):
		_current_attack_indices.append(available_indices[i])
	# Telegraph the attack
	for idx in _current_attack_indices:
		telegraph_tentacle(tentacles[idx])
	# Schedule the actual attack
	await get_tree().create_timer(telegraph_duration).timeout
	# Execute attack
	for idx in _current_attack_indices:
		enable_tentacle(tentacles[idx])
	# Schedule end of attack
	await get_tree().create_timer(attack_duration).timeout
	# End attack
	for idx in _current_attack_indices:
		disable_tentacle(tentacles[idx])
	# Schedule next attack
	_schedule_next_attack()


func telegraph_tentacle(tentacle):
	# Hide the actual tentacle sprite
	if tentacle.has_node("Sprite2D"):
		tentacle.get_node("Sprite2D").visible = false
	# Show warning box indicator
	if tentacle.has_node("WarningBox"):
		# Make warning box visible with telegraph color
		tentacle.get_node("WarningBox").visible = true
		tentacle.get_node("WarningBox").color = telegraph_color
		# Optional: Create a pulsing effect
		var tween = create_tween().set_loops()
		tween.tween_property(tentacle.get_node("WarningBox"), "color:a", 0.3, 0.4)
		tween.tween_property(tentacle.get_node("WarningBox"), "color:a", 0.7, 0.4)
		# Store tween for later cancellation
		tentacle.set_meta("telegraph_tween", tween)


func enable_tentacle(tentacle):
	# Hide warning box
	if tentacle.has_node("WarningBox"):
		tentacle.get_node("WarningBox").visible = false
		# Cancel telegraph animation if it exists
		if tentacle.has_meta("telegraph_tween"):
			var tween = tentacle.get_meta("telegraph_tween")
			if tween and tween.is_valid():
				tween.kill()
	# Enable collision shape to allow damage
	if tentacle.has_node("CollisionShape2D"):
		tentacle.get_node("CollisionShape2D").disabled = false
		tentacle.is_active = true
	# Show the actual tentacle sprite
	if tentacle.has_node("Sprite2D"):
		tentacle.get_node("Sprite2D").visible = true
		tentacle.get_node("Sprite2D").modulate = normal_color
	# Enable any attack animations
	if tentacle.has_method("attack"):
		tentacle.attack()


func disable_tentacle(tentacle):
	# Disable collision shape to prevent damage
	if tentacle.has_node("CollisionShape2D"):
		tentacle.get_node("CollisionShape2D").disabled = true
	# Hide both the tentacle sprite and warning box
	if tentacle.has_node("Sprite2D"):
		tentacle.get_node("Sprite2D").visible = false
	if tentacle.has_node("WarningBox"):
		tentacle.get_node("WarningBox").visible = false
	# Stop any attack animations
	if tentacle.has_method("stop_attack"):
		tentacle.stop_attack()
