extends Area2D

@onready var anim_player = $AnimationPlayer
var is_active = false

func _ready():
	body_entered.connect(_on_body_entered)
	retract() # Ensure tentacle is retracted at start

func _on_body_entered(body):
	# Only damage when the tentacle is active
	if is_active and body is Player:
		body.take_damage()

func attack():
	anim_player.play("attack")

func stop_attack():
	anim_player.play("stop_attack")

func retract():
	# Play the retracted/idle animation (or set to first frame)
	if anim_player.has_animation("retracted"):
		anim_player.play("retracted")
	else:
		# Fallback: set to first frame of the sprite if no animation
		if has_node("CollisionShape2D/Sprite2D"):
			get_node("CollisionShape2D/Sprite2D").frame = 1
