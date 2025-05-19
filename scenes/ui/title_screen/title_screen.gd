extends Control

const BG_FADE_OUT_TIME := 5.0
const TITLE_FADE_IN_TIME := 1.0
const MENU_ITEM_FADE_IN_TIME := 0.5
const TITLE_FADE_OUT_TIME := 1.5
const SHOWN_COLOR := Color(1, 1, 1, 1)
const HIDDEN_COLOR := Color(1, 1, 1, 0)

@export var first_menu_item_focus: NodePath

var is_animation_done := false

@onready var bg_color := $BGColor
@onready var game_title := $Base/GameTitle
@onready var menu_items := $Base/Items


func start_animation() -> void:
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
	await get_tree().create_timer(BG_FADE_OUT_TIME / 3).timeout

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
	for child in menu_items.get_children():
		child.modulate = HIDDEN_COLOR
		var menuitem_fadein = create_tween()
		menuitem_fadein.stop()
		(
			menuitem_fadein
			. tween_property(child, "modulate", Color(SHOWN_COLOR), MENU_ITEM_FADE_IN_TIME)
			. from(HIDDEN_COLOR)
			. set_trans(Tween.TRANS_CUBIC)
			. set_ease(Tween.EASE_OUT)
		)
		menuitem_fadein.play()
		await get_tree().create_timer(MENU_ITEM_FADE_IN_TIME / 2).timeout
	is_animation_done = true

	_grab_focus_first_button()


func _grab_focus_first_button() -> void:
	var first_button: Button = get_node(first_menu_item_focus)
	first_button.grab_focus()


func _ready() -> void:
	game_title.self_modulate = HIDDEN_COLOR
	for child in menu_items.get_children():
		child.modulate = HIDDEN_COLOR
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


func _on_continue_pressed() -> void:  # TODO
	print("CONTINUE")


func _on_newgame_pressed() -> void:  # TODO
	print("NEW GAME")
