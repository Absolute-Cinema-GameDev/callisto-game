extends CharacterBody2D

# Exported variables
@export var speed: float = 10.0
@export var chase_speed: float = 35.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var min_move_time: float = 3.5
@export var max_move_time: float = 5.0
@export var idle_chance: float = 0.3
@export var stun_duration: float = 3.0
@export var patrol_corner_1: Vector2 = Vector2.ZERO
@export var patrol_corner_2: Vector2 = Vector2.ZERO
@export var patrol_corner_3: Vector2 = Vector2.ZERO
@export var patrol_corner_4: Vector2 = Vector2.ZERO

var patrol_zone: Rect2 = Rect2(Vector2.ZERO, Vector2(100, 100))

# State variables
var direction: Vector2 = Vector2.RIGHT
var state: String = "move"
var state_time: float = 0.0
var state_duration: float = 0.0

var can_attack: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 1
var attack_timer: float = 0.0
var attack_box_collision_base_offset: float = 13.0

var is_stunned: bool = false
var stun_timer: float = 0.0

var players_in_vision := []
var player = null

# Onready variables
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var vision_area: Area2D = $VisionArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_box: Area2D = $Sprite2D/AttackBox
@onready var attack_box_collision: CollisionShape2D = $Sprite2D/AttackBox/CollisionShape2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var alert_label: Label = $AlertLabel


func _update_path_to_player():
	if player:
		var target = player.global_position
		# Clamp target to patrol zone
		target.x = clamp(
			target.x, patrol_zone.position.x, patrol_zone.position.x + patrol_zone.size.x
		)
		target.y = clamp(
			target.y, patrol_zone.position.y, patrol_zone.position.y + patrol_zone.size.y
		)
		nav_agent.target_position = target


func _ready() -> void:
	# Compute patrol_zone from 4 corners
	var xs = [patrol_corner_1.x, patrol_corner_2.x, patrol_corner_3.x, patrol_corner_4.x]
	var ys = [patrol_corner_1.y, patrol_corner_2.y, patrol_corner_3.y, patrol_corner_4.y]
	var min_x = xs.min()
	var max_x = xs.max()
	var min_y = ys.min()
	var max_y = ys.max()
	patrol_zone = Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
	attack_box_collision_base_offset = abs(attack_box_collision.position.x)
	_enter_move_state()
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)
	attack_box.body_entered.connect(_on_attack_box_body_entered)
	attack_box.body_exited.connect(_on_attack_box_body_exited)


func _physics_process(delta: float) -> void:
	state_time += delta

	if state == "stun":
		velocity = Vector2.ZERO
		stun_timer += delta
		if not anim_player.is_playing() or anim_player.current_animation != "stun":
			anim_player.play("stun")
		if stun_timer >= stun_duration:
			is_stunned = false
			# Check if player is still in vision and not hidden
			if player and player.is_inside_tree() and not player.is_hidden_from_enemies:
				_enter_chase_state()
			else:
				_enter_move_state()
		return

	if state == "move":
		velocity = direction * speed
		if not anim_player.is_playing() or anim_player.current_animation != "swim":
			anim_player.play("swim")
		if velocity.length() > 1:
			vision_area.rotation = velocity.angle()
		move_and_slide()
		if state_time >= state_duration:
			if randf() < idle_chance:
				_enter_idle_state()
			else:
				_enter_move_state()

	elif state == "idle":
		velocity = Vector2.ZERO
		if not anim_player.is_playing() or anim_player.current_animation != "idle":
			anim_player.play("idle")
		if state_time >= state_duration:
			_enter_move_state()

	elif state == "chase":
		if player and player.is_inside_tree():
			if player.is_hidden_from_enemies:
				_enter_move_state()
				return
			_update_path_to_player()
			var next_point = nav_agent.get_next_path_position()
			var path_direction = (next_point - global_position).normalized()
			velocity = path_direction * chase_speed
			if (
				not anim_player.is_playing()
				or (anim_player.current_animation != "chase" and anim_player.has_animation("chase"))
			):
				if anim_player.has_animation("chase"):
					anim_player.play("chase")
				else:
					anim_player.play("swim")
			if velocity.length() > 1:
				vision_area.rotation = velocity.angle()
			move_and_slide()
		else:
			_enter_move_state()

	elif state == "attack":
		velocity = Vector2.ZERO
		if not can_attack:
			is_attacking = false
			_enter_chase_state()
			return
		if not is_attacking:
			is_attacking = true
			anim_player.play("attack")
			attack_timer = 0.0
			if player and player.is_inside_tree():
				var knockback_direction = (player.global_position - global_position).normalized()
				await get_tree().create_timer(0.3).timeout
				player.apply_knockback(knockback_direction, 70.0, 0.12)
				player.take_damage()
		else:
			attack_timer += delta
			if attack_timer >= attack_cooldown:
				is_attacking = false
				if can_attack:
					_enter_attack_state()
				else:
					_enter_chase_state()

	# Sprite flipping
	var facing_left = false
	if state in ["move", "chase"]:
		if abs(velocity.x) > 0.1:
			facing_left = velocity.x < 0
	elif state == "attack":
		if player and player.is_inside_tree():
			facing_left = (player.global_position.x - global_position.x) < 0

	sprite.flip_h = facing_left
	attack_box_collision.position.x = attack_box_collision_base_offset * (-1 if facing_left else 1)

	# Clamp patrol position to patrol zone
	global_position.x = clamp(
		global_position.x, patrol_zone.position.x, patrol_zone.position.x + patrol_zone.size.x
	)
	global_position.y = clamp(
		global_position.y, patrol_zone.position.y, patrol_zone.position.y + patrol_zone.size.y
	)


func stun():
	if is_stunned:
		return
	is_stunned = true
	stun_timer = 0.0
	state = "stun"
	velocity = Vector2.ZERO
	anim_player.play("stun")


func _enter_move_state():
	state = "move"
	state_time = 0.0
	state_duration = randf_range(min_move_time, max_move_time)
	_set_random_direction()
	if anim_player.has_animation("swim"):
		anim_player.play("swim")


func _enter_idle_state():
	state = "idle"
	state_time = 0.0
	state_duration = randf_range(min_idle_time, max_idle_time)


func _enter_chase_state():
	state = "chase"
	state_time = 0.0
	is_attacking = false
	if anim_player.has_animation("chase"):
		anim_player.play("chase")
	else:
		anim_player.play("swim")


func _enter_attack_state():
	state = "attack"
	state_time = 0.0
	is_attacking = false
	velocity = Vector2.ZERO


func _set_random_direction():
	var tries = 0
	while tries < 10:
		var candidate = Vector2(
			randf_range(patrol_zone.position.x, patrol_zone.position.x + patrol_zone.size.x),
			randf_range(patrol_zone.position.y, patrol_zone.position.y + patrol_zone.size.y)
		)
		if patrol_zone.has_point(candidate):
			direction = (candidate - global_position).normalized()
			return
		tries += 1
	direction = Vector2.RIGHT


func _on_vision_area_body_entered(body):
	if body is Player:
		if not players_in_vision.has(body):
			players_in_vision.append(body)
		if not body.is_hidden_from_enemies_changed.is_connected(_on_player_hidden_changed):
			body.is_hidden_from_enemies_changed.connect(_on_player_hidden_changed.bind(body))
		if not body.is_hidden_from_enemies:
			alert_label.visible = true
			await get_tree().create_timer(0.5).timeout
			alert_label.visible = false
			player = body
			_update_path_to_player()
			_enter_chase_state()


func _on_vision_area_body_exited(body):
	if body is Player:
		if players_in_vision.has(body):
			players_in_vision.erase(body)
		if body.is_hidden_from_enemies_changed.is_connected(_on_player_hidden_changed.bind(body)):
			body.is_hidden_from_enemies_changed.disconnect(_on_player_hidden_changed.bind(body))
		if player == body:
			player = null
			_enter_move_state()


func _on_attack_box_body_entered(body):
	if body is Player:
		print("in")
		can_attack = true
		if state == "chase":
			_enter_attack_state()


func _on_attack_box_body_exited(body):
	if body is Player:
		await get_tree().create_timer(0.3).timeout
		print("out")
		can_attack = false
		if state == "attack":
			_enter_chase_state()


func _on_player_hidden_changed(is_hidden: bool, changed_player) -> void:
	if not is_hidden and players_in_vision.has(changed_player):
		player = changed_player
		_enter_chase_state()
		return
	# If no visible players, stop chasing
	for p in players_in_vision:
		print(p)
		if not p.is_hidden_from_enemies:
			player = p
			_enter_chase_state()
			return
	if player != null:
		player = null
		_enter_move_state()
