extends Control


func splash_screen_done() -> void:
	# TODO: change scene when done
	print("A game by Absolute Cinema")
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		splash_screen_done()


func _ready() -> void:
	var teamlogo = $TeamLogo
	var tween = create_tween()
	tween.tween_property(teamlogo, "self_modulate", Color(1, 1, 1, 1), 1).from(Color(1, 1, 1, 0))
	await get_tree().create_timer(3).timeout
	var tween2 = create_tween()
	tween2.tween_property(teamlogo, "self_modulate", Color(1, 1, 1, 0), 2)
	splash_screen_done()
