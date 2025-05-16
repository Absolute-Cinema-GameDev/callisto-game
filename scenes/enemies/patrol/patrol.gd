extends CharacterBody2D

@export var speed: float = 10.0
@export var chase_speed: float = 50.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var min_move_time: float = 3.5
@export var max_move_time: float = 5.0
@export var idle_chance: float = 0.3

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var vision_area: Area2D = $VisionArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var player: Player = $"../Player"

var direction: Vector2 = Vector2.RIGHT
var state: String = "move"
var state_time: float = 0.0
var state_duration: float = 0.0

func _ready() -> void:
	_enter_move_state()
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)

func _physics_process(delta: float) -> void:
	state_time += delta

	if state == "move":
		velocity = direction * speed
		if not anim_player.is_playing() or anim_player.current_animation != "swim":
			anim_player.play("swim")
		if abs(velocity.x) > 0.1:
			sprite.flip_h = velocity.x < 0
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
			var to_player = (player.global_position - global_position).normalized()
			velocity = to_player * chase_speed
			if not anim_player.is_playing() or anim_player.current_animation != "swim":
				anim_player.play("swim")
			if abs(velocity.x) > 0.1:
				sprite.flip_h = velocity.x < 0
			if velocity.length() > 1:
				vision_area.rotation = velocity.angle()
			move_and_slide()
		else:
			# Player lost, return to patrol
			_enter_move_state()

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

func _set_random_direction():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT

func _on_vision_area_body_entered(body):
	if body is Player:
		player = body
		_enter_chase_state()

func _on_vision_area_body_exited(body):
	if body == player:
		player = null
		_enter_move_state()
