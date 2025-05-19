extends Control

const BG_FADE_OUT_TIME := 3.0
const TITLE_FADE_IN_TIME := 1.0
const TITLE_FADE_OUT_TIME := 1.5
const SHOWN_COLOR := Color(1, 1, 1, 1)
const HIDDEN_COLOR := Color(1, 1, 1, 0)

@export var first_menu_item_focus: NodePath

var is_animation_done := false

@onready var bg_color := $BGColor
@onready var game_title := $Base/GameTitle
@onready var menu_items := $Base/Items


func start_animation() -> void:
	game_title.self_modulate = HIDDEN_COLOR
	menu_items.modulate = HIDDEN_COLOR

	# 1. bg fade out
	var bg_fadeout = create_tween()
	bg_fadeout.stop()
	(
		bg_fadeout
		. tween_property(bg_color, "self_modulate", Color(HIDDEN_COLOR), BG_FADE_OUT_TIME)
		. from(SHOWN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	bg_fadeout.play()
	await get_tree().create_timer(BG_FADE_OUT_TIME / 2).timeout

	# 2. title fade in
	var title_fadein = create_tween()
	title_fadein.stop()
	(
		title_fadein
		. tween_property(game_title, "self_modulate", Color(SHOWN_COLOR), TITLE_FADE_IN_TIME)
		. from(HIDDEN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	title_fadein.play()
	await title_fadein.finished

	# 3. menu fade in
	var menuitems_fadein = create_tween()
	menuitems_fadein.stop()
	(
		menuitems_fadein
		. tween_property(menu_items, "modulate", Color(SHOWN_COLOR), TITLE_FADE_IN_TIME)
		. from(HIDDEN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	menuitems_fadein.play()
	await menuitems_fadein.finished
	is_animation_done = true

	_grab_focus_first_button()


func _grab_focus_first_button() -> void:
	var first_button: Button = get_node(first_menu_item_focus)
	first_button.grab_focus()


func _ready() -> void:
	start_animation()


func _unhandled_input(event: InputEvent) -> void:
	if (
		get_viewport().gui_get_focus_owner() == null
		and is_animation_done
		and (
			event.is_action("ui_up")
			or event.is_action("ui_down")
			or event.is_action("ui_left")
			or event.is_action("ui_right")
		)
	):
		_grab_focus_first_button()


func _on_continue_pressed() -> void:
	print("CONTINUE")


func _on_newgame_pressed() -> void:
	print("NEW GAME")
