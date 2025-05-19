extends Control

const LOGO_FADE_IN_TIME := 1.0
const LOGO_FADE_OUT_TIME := 1.5
const SPLASH_SCREEN_HANG_TIME := 2.0
const LOGO_SHOWN_COLOR := Color(1, 1, 1, 1)
const LOGO_HIDDEN_COLOR := Color(1, 1, 1, 0)


func splash_screen_done() -> void:
	# TODO: change scene when done
	print("A game by Absolute Cinema")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		splash_screen_done()


func _ready() -> void:
	var teamlogo = $TeamLogo
	var tween = create_tween()
	(
		tween
		. tween_property(teamlogo, "self_modulate", Color(LOGO_SHOWN_COLOR), LOGO_FADE_IN_TIME)
		. from(LOGO_HIDDEN_COLOR)
	)
	await get_tree().create_timer(SPLASH_SCREEN_HANG_TIME).timeout
	var tween2 = create_tween()
	tween2.tween_property(teamlogo, "self_modulate", Color(LOGO_HIDDEN_COLOR), LOGO_FADE_OUT_TIME)
	splash_screen_done()
