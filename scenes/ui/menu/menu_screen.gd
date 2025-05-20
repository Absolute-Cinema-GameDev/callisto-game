class_name MenuScreen

extends Control

const SHOWN_COLOR := Color(1, 1, 1, 1)
const HIDDEN_COLOR := Color(1, 1, 1, 0)

@export var first_menu_item_focus: NodePath

var is_animation_done := false
var game_controller: GameController


func appear_animation() -> void:
	pass


func disappear_animation() -> void:
	pass


func _ready() -> void:
	pass


func _grab_focus_first_button() -> void:
	if first_menu_item_focus == null:
		return
	var first_button: Button = get_node(first_menu_item_focus)
	first_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if (
		get_viewport().gui_get_focus_owner() == null
		and self.is_animation_done
		and (
			event.is_action("ui_up")
			or event.is_action("ui_down")
			or event.is_action("ui_left")
			or event.is_action("ui_right")
		)
	):
		_grab_focus_first_button()
