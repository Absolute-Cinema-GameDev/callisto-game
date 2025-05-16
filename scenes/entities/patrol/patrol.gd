extends CharacterBody2D

@export var speed: float = 10.0
@export var chase_speed: float = 25.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var min_move_time: float = 3.5
@export var max_move_time: float = 5.0
@export var idle_chance: float = 0.3
@export var stun_duration: float = 2.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var vision_area: Area2D = $VisionArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var player: Player = $"../Player"
@onready var attack_box: Area2D = $Sprite2D/AttackBox


var direction: Vector2 = Vector2.RIGHT
var state: String = "move"
var state_time: float = 0.0
var state_duration: float = 0.0

var can_attack: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0
var attack_box_base_offset: float 

var is_stunned: bool = false
var stun_timer: float = 0.0

func _ready() -> void:
	attack_box_base_offset = attack_box.position.x
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
			_enter_move_state()
		# Flipping logic (optional, usually not needed when stunned)
		# sprite.flip_h = false
		# attack_box.position.x = attack_box_base_offset
		return

	elif state == "move":
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
			# If player hides, stop chasing
			if player.is_hidden_from_enemies:
				player = null
				_enter_move_state()
				return
			var to_player = (player.global_position - global_position).normalized()
			velocity = to_player * chase_speed
			if velocity.length() > 1:
				vision_area.rotation = velocity.angle()
			move_and_slide()
		else:
			_enter_move_state()
	
	elif state == "attack":
		velocity = Vector2.ZERO
		if not is_attacking:
			is_attacking = true
			anim_player.play("attack")
			attack_timer = 0.0
			# Damage player
			if player and player.is_inside_tree():
				player.take_damage()
		else:
			attack_timer += delta
			if attack_timer >= attack_cooldown:
				is_attacking = false
				if can_attack:
					_enter_attack_state()
				else:
					_enter_chase_state()

	var facing_left = false
	if state in ["move", "chase"]:
		if abs(velocity.x) > 0.1:
			facing_left = velocity.x < 0
	elif state == "attack":
		if player and player.is_inside_tree():
			facing_left = (player.global_position.x - global_position.x) < 0

	sprite.flip_h = facing_left
	attack_box.position.x = attack_box_base_offset * (-1 if facing_left else 1)

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

func _enter_idle_state():
	state = "idle"
	state_time = 0.0
	state_duration = randf_range(min_idle_time, max_idle_time)

func _enter_chase_state():
	state = "chase"
	state_time = 0.0

func _enter_attack_state():
	state = "attack"
	state_time = 0.0
	is_attacking = false
	velocity = Vector2.ZERO

func _set_random_direction():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT

func _on_vision_area_body_entered(body):
	if body is Player:
		if not body.is_hidden_from_enemies:
			player = body
			_enter_chase_state()

func _on_vision_area_body_exited(body):
	if body == player:
		player = null
		_enter_move_state()

func _on_attack_box_body_entered(body):
	if body is Player:
		can_attack = true
		if state == "chase":
			_enter_attack_state()

func _on_attack_box_body_exited(body):
	if body is Player:
		can_attack = false
		if state == "attack":
			_enter_chase_state()
