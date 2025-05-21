extends MenuScreen

const BG_FADE_OUT_TIME := 0.5
const TITLE_FADE_IN_TIME := 0.0
const MENU_ITEM_FADE_IN_TIME := 0.2
const TITLE_FADE_OUT_TIME := 0.2
const BG_SHOWN_COLOR := Color(1, 1, 1, 0.8)

@onready var bg_color := $BGColor
@onready var warning_message := $Base/Message
@onready var menu_items := $Base/Items


func _ready() -> void:
	game_controller = Globals.game_controller
	_grab_focus_first_button()
	is_animation_done = true


func _on_continue_pressed() -> void:
	game_controller.set_paused(false)


func _on_quit_pressed() -> void:
	game_controller.change_world_2d_scene(GameController.MENU_BACKGROUND)
	game_controller.change_gui_scene(GameController.TITLE_SCREEN)
	game_controller.set_paused(false)
