extends CharacterBody2D

@export var speed: float = 10.0
@export var change_direction_time: float = 2.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var vision_area: Node2D = $VisionArea
@onready var sprite: Sprite2D = $Sprite2D

var direction: Vector2 = Vector2.RIGHT
var time_accum: float = 0.0

func _ready() -> void:
	_set_random_direction()

func _physics_process(delta: float) -> void:
	# Autonomous movement
	velocity = direction * speed
	move_and_slide()

	# Animation sync
	if velocity.length() > 1:
		if not anim_player.is_playing() or anim_player.current_animation != "swim":
			anim_player.play("swim")
	else:
		if not anim_player.is_playing() or anim_player.current_animation != "idle":
			anim_player.play("idle")

	# Flip sprite if moving left or right
	if abs(velocity.x) > 0.1:
		sprite.flip_h = velocity.x < 0

	# Change direction timer
	time_accum += delta
	if time_accum >= change_direction_time:
		_set_random_direction()
		time_accum = 0.0

func _set_random_direction():
	# Pick a random normalized direction
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if direction.length() < 0.1:
		direction = Vector2.RIGHT
