extends MenuScreen

const BG_FADE_OUT_TIME := 5.0
const TITLE_FADE_IN_TIME := 1.0
const MENU_ITEM_FADE_IN_TIME := 0.5
const TITLE_FADE_OUT_TIME := 0.2

@onready var bg_color := $BGColor
@onready var game_title := $Base/GameTitle
@onready var menu_items := $Base/Items


func appear_animation() -> void:
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


func disappear_animation() -> void:
	# 1. bg fade in
	var bg_fadein = create_tween()
	bg_fadein.stop()
	(
		bg_fadein
		. tween_property(bg_color, "self_modulate", Color(SHOWN_COLOR), TITLE_FADE_OUT_TIME)
		. from(HIDDEN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	bg_fadein.play()

	# 2. title fade in
	var title_fadeout = create_tween()
	title_fadeout.stop()
	(
		title_fadeout
		. tween_property(game_title, "self_modulate", Color(HIDDEN_COLOR), TITLE_FADE_OUT_TIME)
		. from(SHOWN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	title_fadeout.play()

	# 3. menu fade in
	var menuitems_fadeout = create_tween()
	menuitems_fadeout.stop()
	(
		menuitems_fadeout
		. tween_property(menu_items, "modulate", Color(HIDDEN_COLOR), TITLE_FADE_OUT_TIME)
		. from(SHOWN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	menuitems_fadeout.play()
	await get_tree().create_timer(TITLE_FADE_OUT_TIME).timeout


func _ready() -> void:
	game_controller = Globals.game_controller
	game_title.self_modulate = HIDDEN_COLOR
	for child in menu_items.get_children():
		child.modulate = HIDDEN_COLOR

	# Hide and disable Continue button if no save file detected
	if not self.game_controller.check_save_file_exists():
		first_menu_item_focus = "./Base/Items/NewGame/Layout/Button"
		$Base/Items/Continue.visible = false
		$Base/Items/Continue.queue_free()
	await appear_animation()
	_grab_focus_first_button()


func _on_continue_pressed() -> void:
	await disappear_animation()
	## 2D: load level that's saved
	game_controller.change_world_2d_scene(game_controller.level_select())

	## GUI: load HUD
	game_controller.change_gui_scene(GameController.HUD)


func _on_newgame_pressed() -> void:
	await disappear_animation()
	if game_controller.check_save_file_exists():
		game_controller.change_gui_scene(GameController.NEW_GAME_WARNING)
	else:
		## 2D: load level that's saved
		game_controller.change_world_2d_scene(game_controller.level_select())

		## GUI: load HUD
		game_controller.change_gui_scene(GameController.HUD)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("exit_game"):
		get_tree().quit()
