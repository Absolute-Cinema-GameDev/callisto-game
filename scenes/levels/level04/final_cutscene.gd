extends Node2D

@onready var white_overlay = $WhiteOverlay
@onready var text = $CanvasLayer/Label


# Attach to DriftScene or use in script
func _ready():
	white_overlay.visible = false
	var tween = create_tween()
	# Move the player slowly downward
	(
		tween
		. tween_property($Player, "position:y", $Player.position.y + 500, 90.0)
		. set_trans(Tween.TRANS_LINEAR)
		. set_ease(Tween.EASE_IN_OUT)
	)


func _on_text_trigger_body_entered(_body: Node2D) -> void:
	text.start_typing("So this is how it ends...")
	await get_tree().create_timer(3).timeout
	text.start_deleting()


func _on_text_trigger_2_body_entered(_body: Node2D) -> void:
	text.start_typing('Distant Voice: "…Look there… someone’s there"')
	await get_tree().create_timer(5).timeout
	text.start_deleting()


func _on_text_trigger_3_body_entered(_body: Node2D) -> void:
	text.start_typing("...Light?")
	await get_tree().create_timer(3).timeout
	text.start_deleting()
