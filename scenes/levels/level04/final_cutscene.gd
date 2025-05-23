extends Node2D

# Attach to DriftScene or use in script
func _ready():
	var tween = create_tween()
	# Move the player slowly downward
	tween.tween_property($Player, "position:y", $Player.position.y + 500, 60.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
