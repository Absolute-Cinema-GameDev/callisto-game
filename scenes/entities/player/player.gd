class_name Player

extends CharacterBody2D

signal movement_type_changed  ## Fires when movement_type is changed
signal health_changed  ## Fires when health_status is changed
signal is_invincible_changed  ## Fires when is_invincible is changed
signal main_oxygen_changed  ## Fires when main_tank_capacity is changed
signal reserve_oxygen_changed  ## Fires when reserve_tank_capacity is changed
signal is_in_airpocket_changed  ## Fires when player moves in/out of airpockets
signal is_hidden_from_enemies_changed  ## Fires when player moves in/out of seaweed bushes
signal is_stunned_changed  ## Fires when player stun status is changed
signal is_input_locked_changed  ## Fires when player input lock status is changed

enum MovementType { WALK, SWIM }
enum HealthStatus { HEALTHY, CRITICAL, DEAD }

const WALK_ACCELERATION: float = 60.0
const WALK_DECELERATION: float = 60.0
const SWIM_ACCELERATION: float = 5.0
const SWIM_DECELERATION: float = 3.0
const GRAVITY: float = 1200.0
const MAX_OXYGEN_MAIN: float = 100.0
const MAX_OXYGEN_RESERVE: float = 50.0
const OXYGEN_MAIN_GAIN_RATE: float = 10
const OXYGEN_MAIN_DECAY_RATE: float = 1
const OXYGEN_RESERVE_DECAY_RATE: float = 1

@export var movement_speed: float = 120.0
@export var movement_type: MovementType = MovementType.SWIM:
	get = get_movement_type,
	set = _set_movement_type
@export var health_status: HealthStatus = HealthStatus.HEALTHY:
	get = get_health_status,
	set = _set_health_status
@export var main_tank_capacity: float = MAX_OXYGEN_MAIN:
	get = get_main_tank_capacity,
	set = _set_main_tank_capacity
@export var reserve_tank_capacity: float = MAX_OXYGEN_RESERVE:
	get = get_reserve_tank_capacity,
	set = _set_reserve_tank_capacity
@export var is_in_airpocket: bool = false:
	get = get_is_in_airpocket,
	set = set_is_in_airpocket
@export var is_invincible: bool = false:
	get = get_is_invincible,
	set = _set_is_invincible
@export var is_hidden_from_enemies: bool = false:
	get = get_is_hidden_from_enemies,
	set = set_is_hidden_from_enemies
@export var is_stunned: bool = false:
	get = get_is_stunned,
	set = _set_is_stunned
@export var is_input_locked: bool = false:
	get = get_is_input_locked,
	set = set_is_input_locked

@onready var animplayer: AnimatedSprite2D = $Animate
@onready var interact_ray: RayCast2D = $InteractRay
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var heal_timer: Timer = $HealTimer
@onready var stun_timer: Timer = $StunTimer
@onready var hurtbox: CollisionShape2D = $Hurtbox  ## Use this for damage calculation
@onready var collision_box: CollisionShape2D = $CollisionBox

#-- GETTERS


func get_health_status() -> HealthStatus:
	return health_status


func get_movement_type() -> MovementType:
	return movement_type


func get_main_tank_capacity() -> float:
	return main_tank_capacity


func get_reserve_tank_capacity() -> float:
	return reserve_tank_capacity


func get_is_in_airpocket() -> bool:
	return is_in_airpocket


func get_is_invincible() -> bool:
	return is_invincible


func get_is_hidden_from_enemies() -> bool:
	return is_hidden_from_enemies


func get_is_stunned() -> bool:
	return is_stunned

func get_is_input_locked() -> bool:
	return is_input_locked


#-- SETTERS


func _set_health_status(value: HealthStatus):
	health_status = value
	health_changed.emit(value)


func _set_movement_type(value: MovementType):
	movement_type_changed.emit(value)
	movement_type = value


func _set_main_tank_capacity(value: float):
	main_oxygen_changed.emit(value)
	main_tank_capacity = value


func _set_reserve_tank_capacity(value: float):
	if value > reserve_tank_capacity:
		reserve_oxygen_changed.emit(value)
		reserve_tank_capacity = value


func set_is_in_airpocket(value: bool):
	is_in_airpocket_changed.emit(value)
	is_in_airpocket = value


func _set_is_invincible(value: bool):
	is_invincible_changed.emit(value)
	is_invincible = value


func set_is_hidden_from_enemies(value: bool):
	is_hidden_from_enemies_changed.emit(value)
	is_hidden_from_enemies = value


func _set_is_stunned(value: bool):
	is_stunned_changed.emit(value)
	is_stunned = value


func set_is_input_locked(value: bool):
	is_input_locked_changed.emit(value)
	is_input_locked = value


#-- MOVEMENT


## Adjust sprite direction
func _adjust_sprite_direction(is_flipped: bool) -> void:
	animplayer.flip_h = is_flipped
	hurtbox.position.x = 2 if is_flipped else -2
	collision_box.position.x = 2 if is_flipped else -2
	interact_ray.target_position.x = -36 if is_flipped else 36


## Movement while underwater (e.g: in Cave)
func _move_swim(input_vector: Vector2) -> void:
	var is_moving: bool = false

	# Update velocity.x
	if input_vector.x != 0:
		is_moving = true
		velocity.x = lerp(
			velocity.x, movement_speed * input_vector.x, SWIM_ACCELERATION / movement_speed
		)
		_adjust_sprite_direction(input_vector.x < 0)

	else:
		velocity.x = lerp(velocity.x, 0.0, SWIM_DECELERATION / movement_speed)

	# Update velocity.y
	if input_vector.y != 0:
		is_moving = true
		velocity.y = lerp(
			velocity.y, movement_speed * input_vector.y, SWIM_ACCELERATION / movement_speed
		)
	else:
		velocity.y = lerp(velocity.y, 0.0, SWIM_DECELERATION / movement_speed)

	_change_animation(is_moving)


## Movement while on land (e.g: Poseidon-1 Station Hub)
func _move_walk(input_vector: Vector2) -> void:
	var is_moving: bool = false

	# Update velocity.x
	if input_vector.x != 0:
		is_moving = true
		velocity.x = lerp(
			velocity.x, movement_speed * input_vector.x, WALK_ACCELERATION / movement_speed
		)
		_adjust_sprite_direction(input_vector.x < 0)
	else:
		velocity.x = lerp(velocity.x, 0.0, WALK_DECELERATION / movement_speed)

	_change_animation(is_moving)


## Change currently playing animation based on player moving state
func _change_animation(is_moving: bool) -> void:
	if movement_type == MovementType.SWIM:
		if is_moving:
			animplayer.play("swim_move")
		else:
			animplayer.play("swim_idle")
	else:
		if is_moving:
			animplayer.play("walk_move")
		else:
			animplayer.play("walk_idle")


## Every physics frame, process movement
func _physics_process(_delta: float) -> void:
	var input_vector = Vector2.ZERO
	if not is_stunned and not is_input_locked:  # Keep vector at ZERO when stunned
		input_vector.x = (
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		)
		input_vector.y = (
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		)
		input_vector = input_vector.normalized()

	if movement_type == MovementType.SWIM:
		_move_swim(input_vector)
	elif movement_type == MovementType.WALK:
		_move_walk(input_vector)
		velocity.y += _delta * GRAVITY

	move_and_slide()


#-- HEALTH


## Reverts [member health_status] one step back.
## Example: HEALTHY -> CRITICAL, CRITICAL -> DEAD
func take_damage():
	if is_invincible:
		return
	if health_status == HealthStatus.HEALTHY:  # Reduce to critical state
		health_status = HealthStatus.CRITICAL
	else:  # Player is dead, restart level
		health_status = HealthStatus.DEAD


func _on_health_changed(new_health) -> void:
	if new_health == HealthStatus.HEALTHY:
		animplayer.set_self_modulate(Color(1, 1, 1, 1))
	elif new_health == HealthStatus.CRITICAL:
		animplayer.set_self_modulate(Color(1, 0, 0, 1))

		# 1 second of invincibility
		is_invincible = true
		invincible_timer.start()
		heal_timer.start()
	elif new_health == HealthStatus.DEAD:
		animplayer.set_self_modulate(Color(0.25, 0, 0, 1))


func _on_invincible_timer_timeout() -> void:
	is_invincible = false


func _on_heal_timer_timeout() -> void:
	if health_status == HealthStatus.CRITICAL:
		health_status = HealthStatus.HEALTHY


func _on_test_timer_timeout() -> void:
	# TODO: ini testing buat damage aja
	stun()


#-- INTERACTION


## Interact with world objects
func _interact():
	# TODO: interaction yang perlu input dari player
	print("interact...")
	var collider = interact_ray.get_collider()

	if interact_ray.is_colliding():
		collider.interact()


## Handle gameplay input
func _unhandled_input(event: InputEvent) -> void:
	if is_input_locked:
		return
	if event.is_action_pressed("interact"):
		_interact()


#-- OXYGEN
func _on_oxygen_timer_timeout() -> void:
	if is_in_airpocket or movement_type == MovementType.WALK:
		main_tank_capacity += OXYGEN_MAIN_GAIN_RATE
		return
	if main_tank_capacity > 0:
		main_tank_capacity -= OXYGEN_MAIN_DECAY_RATE
	elif reserve_tank_capacity > 0:
		reserve_tank_capacity -= OXYGEN_RESERVE_DECAY_RATE
	else:
		if health_status != HealthStatus.DEAD:
			take_damage()


#-- STUN ROCK


func stun() -> void:
	is_stunned = true
	stun_timer.start()


func _on_stun_timer_timeout() -> void:
	is_stunned = false


func _on_is_stunned_changed(new_stun_value) -> void:
	if new_stun_value:
		animplayer.set_self_modulate(Color(1, 1, 0, 1))
	else:
		animplayer.set_self_modulate(Color(1, 1, 1, 1))


#-- SEAWEED BUSH
func _on_is_hidden_from_enemies_changed(new_value) -> void:
	if new_value:
		animplayer.set_self_modulate(Color(0.7, 0.7, 0.7, 1))
	else:
		animplayer.set_self_modulate(Color(1, 1, 1, 1))
