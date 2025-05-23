extends Area2D

@onready var anim_player = $AnimationPlayer
var is_active = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Only damage when the tentacle is active
	if is_active and body is Player:
		body.take_damage()

func attack():
	anim_player.play("attack")

func stop_attack():
	anim_player.play("stop_attack")
	
