extends MenuScreen

const BG_FADE_OUT_TIME := 0.5
const TITLE_FADE_IN_TIME := 0.0
const MENU_ITEM_FADE_IN_TIME := 0.2
const TITLE_FADE_OUT_TIME := 0.2
const BG_SHOWN_COLOR := Color(1, 1, 1, 0.8)

@onready var bg_color := $BGColor
@onready var menu_base := $Base
@onready var warning_message := $Base/Message
@onready var menu_items := $Base/Items


func appear_animation() -> void:
	# 1. bg fade out
	var bg_fadeout = create_tween()
	bg_fadeout.stop()
	(
		bg_fadeout
		. tween_property(bg_color, "self_modulate", Color(BG_SHOWN_COLOR), BG_FADE_OUT_TIME)
		. from(SHOWN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	bg_fadeout.play()

	# 2. title fade in
	var base_fadein = create_tween()
	base_fadein.stop()
	(
		base_fadein
		. tween_property(menu_base, "modulate", Color(SHOWN_COLOR), TITLE_FADE_IN_TIME)
		. from(HIDDEN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	base_fadein.play()
	await base_fadein.finished

	is_animation_done = true


func disappear_animation() -> void:
	# 1. bg fade in
	var bg_fadein = create_tween()
	bg_fadein.stop()
	(
		bg_fadein
		. tween_property(bg_color, "self_modulate", Color(SHOWN_COLOR), TITLE_FADE_OUT_TIME)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)

	# 2. title fade in
	var base_fadeout = create_tween()
	base_fadeout.stop()
	(
		base_fadeout
		. tween_property(menu_base, "modulate", Color(HIDDEN_COLOR), TITLE_FADE_OUT_TIME)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)

	bg_fadein.play()
	base_fadeout.play()
	await base_fadeout.finished


func _ready() -> void:
	game_controller = Globals.game_controller

	await appear_animation()
	_grab_focus_first_button()


func _on_proceed_pressed() -> void:
	await disappear_animation()
	game_controller.current_chapter = GameController.Chapter.INTRO
	game_controller.current_checkpoint = GameController.Checkpoint.START
	## 2D: load level that's saved
	game_controller.change_world_2d_scene(game_controller.level_select())

	## GUI: load HUD
	game_controller.change_gui_scene(GameController.HUD)


func _on_return_pressed() -> void:
	await disappear_animation()
	game_controller.change_gui_scene(GameController.TITLE_SCREEN)
