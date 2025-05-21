extends CharacterBody2D

enum State { IDLE, ACTIVE, ATTACKING, HIT_PAUSE, RETURNING }

var state: State = State.IDLE
var spawn_position: Vector2
var target_position: Vector2
var dash_speed: float = 50.0
var dash_delay: float = 0.1
var active_wait_time: float = 2.0
var hit_pause_time: float = 0.5
var stun_duration: float = 2.0
var is_stun: bool = false  # For future stun rock mechanic
var active_timer := Timer.new()
var dash_timer := Timer.new()
var hit_pause_timer := Timer.new()
var stun_timer := Timer.new()

@onready var area_detection = $AreaDetection
@onready var collision_shape = $Collision
@onready var anim = $Animate


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_position = global_position
	# Setup timers
	active_timer.wait_time = active_wait_time
	active_timer.one_shot = true
	add_child(active_timer)
	active_timer.timeout.connect(_on_active_timer_timeout)

	dash_timer.wait_time = dash_delay
	dash_timer.one_shot = true
	add_child(dash_timer)
	dash_timer.timeout.connect(_on_dash_timer_timeout)

	hit_pause_timer.wait_time = hit_pause_time
	hit_pause_timer.one_shot = true
	add_child(hit_pause_timer)
	hit_pause_timer.timeout.connect(_on_hit_pause_timer_timeout)

	stun_timer.wait_time = stun_duration
	stun_timer.one_shot = true
	add_child(stun_timer)
	stun_timer.timeout.connect(_on_stun_timer_timeout)
	area_detection.body_entered.connect(_on_area_body_entered)
	area_detection.body_exited.connect(_on_area_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_stun:
		if anim.animation != "stun":
			anim.play("stun")
			velocity = Vector2.ZERO
		return
	if state == State.ATTACKING:
		if anim.animation != "dash":
			anim.play("dash")
		# Flip sprite to face dash direction
		anim.flip_h = (target_position.x < global_position.x)
		# Move towards target position
		var direction = (target_position - global_position).normalized()
		velocity = direction * dash_speed
		move_and_slide()
		# Check for collision with player after moving
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider() is Player:
				var knockback_direction = (
					(collision.get_collider().global_position - global_position).normalized()
				)
				collision.get_collider().apply_knockback(knockback_direction, 50.0, 0.12)
				collision.get_collider().take_damage()
				velocity = Vector2.ZERO
				state = State.HIT_PAUSE
				hit_pause_timer.start()
				break
		# Check if reached or passed target
		if global_position.distance_to(target_position) < 1 and state == State.ATTACKING:
			velocity = Vector2.ZERO
			state = State.RETURNING
	elif state == State.HIT_PAUSE:
		velocity = Vector2.ZERO
	elif state == State.RETURNING:
		if anim.animation != "active":
			anim.play("active")
		# Flip sprite to face spawn direction
		anim.flip_h = (spawn_position.x < global_position.x)
		# Move back to spawn
		var direction = (spawn_position - global_position).normalized()
		velocity = direction * dash_speed
		move_and_slide()
		if global_position.distance_to(spawn_position) < 10:
			velocity = Vector2.ZERO
			state = State.IDLE
			# Immediately check if player is in area
	elif state == State.ACTIVE:
		if anim.animation != "active":
			anim.play("active")
		# Flip sprite to face player
		var player = _get_player_in_area()
		if player:
			anim.flip_h = (player.global_position.x < global_position.x)
	else:
		if _get_player_in_area() != null:
			state = State.ACTIVE
			active_timer.start()
		if anim.animation != "idle":
			anim.play("idle")
		velocity = Vector2.ZERO


func _on_area_body_entered(body):
	if state == State.IDLE and body is Player:
		if not body.get_is_hidden_from_enemies():
			state = State.ACTIVE
			active_timer.start()


func _on_area_body_exited(_body):
	# Optional: if you want to reset if player leaves before attack
	pass


func _on_active_timer_timeout():
	# Lock player position
	var player = _get_player_in_area()
	if player:
		target_position = player.global_position
		state = State.ATTACKING
		dash_timer.start()
	else:
		state = State.IDLE


func _on_dash_timer_timeout():
	# Start dashing to target
	# (actual dash handled in _process)
	pass


func _get_player_in_area():
	for body in area_detection.get_overlapping_bodies():
		if body is Player:
			if not body.get_is_hidden_from_enemies():
				return body
	return null


func _on_hit_pause_timer_timeout():
	state = State.RETURNING


# Call this to stun the ambush (for future stun rock, etc)
func stun():
	is_stun = true
	velocity = Vector2.ZERO
	stun_timer.start()


func _on_stun_timer_timeout():
	is_stun = false
	state = State.RETURNING
