class_name MenuItem

extends MarginContainer

enum MenuAction { CONTINUE, NEW_GAME, RETURN, QUIT }

const MARGIN_RIGHT_FOCUSED := 22
const MARGIN_RIGHT_UNFOCUSED := 0

@export var action: MenuAction

@onready var layout := $Layout
@onready var indicator := $Layout/Indicator
@onready var button := $Layout/Button
@onready var focus_sfx := $FocusSFX
@onready var pressed_sfx := $PressedSFX


func change_appearance(is_focused: bool) -> void:
	if is_focused and not button.disabled:
		indicator.visible = true
		add_theme_constant_override("margin_right", MARGIN_RIGHT_FOCUSED)
	else:
		indicator.visible = false
		add_theme_constant_override("margin_right", MARGIN_RIGHT_UNFOCUSED)


func _ready() -> void:
	change_appearance(button.has_focus())


func _on_button_focus_entered() -> void:
	focus_sfx.play()
	change_appearance(true)


func _on_button_focus_exited() -> void:
	change_appearance(false)


func _on_button_mouse_entered() -> void:
	button.grab_focus()


func _on_button_mouse_exited() -> void:
	button.release_focus()


func _on_button_pressed() -> void:
	pressed_sfx.play()
