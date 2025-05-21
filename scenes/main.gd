class_name GameController

extends Node

signal world_2d_scene_changed
signal gui_scene_changed
signal pause_state_changed
signal story_progressed
signal game_saving
signal game_saved
signal game_loaded

enum Chapter { INTRO, SAVE001, SAVE002, SAVE003 }
enum Checkpoint { START, DIVING, FOUND, SURFACED }

const ROOT_LEVELS_PATH = "res://scenes/levels/"
const POSEIDON_HUB = ROOT_LEVELS_PATH + "hub/poseidon_hub.tscn"  # TODO: adjust sesuai path
const LEVEL_01 = ROOT_LEVELS_PATH + "level01/level01.tscn"  # TODO: adjust sesuai path
const LEVEL_02 = ROOT_LEVELS_PATH + "level02/level02.tscn"
const LEVEL_03 = ROOT_LEVELS_PATH + "level03/level03.tscn"
const LEVEL_04 = ROOT_LEVELS_PATH + "level04/level04.tscn"
const CAMERA_TEST = ROOT_LEVELS_PATH + "cameratest/camera_test.tscn"  # todo: REMOVE

const BACKGROUNDS_PATH = ROOT_LEVELS_PATH + "backgrounds/"
const MENU_BACKGROUND = BACKGROUNDS_PATH + "menu_bg.tscn"
const CREDITS_BACKGROUND = BACKGROUNDS_PATH + "credits_bg.tscn"

const ROOT_UI_PATH = "res://scenes/ui/"
const SPLASH_SCREEN = ROOT_UI_PATH + "splash_screen/splash_screen.tscn"  # TODO: adjust sesuai path
const TITLE_SCREEN = ROOT_UI_PATH + "title_screen/title_screen.tscn"
const PAUSE_MENU = ROOT_UI_PATH + "pause_menu/pause_menu.tscn"
const HUD = ROOT_UI_PATH + "hud/hud.tscn"
const NEW_GAME_WARNING = ROOT_UI_PATH + "new_game_warning_screen/new_game_warning_screen.tscn"
const CREDITS_SCREEN = ROOT_UI_PATH + "credits_screen/scredits_screen.tscn"

const SAVE_FILE_PATH = "user://savegame.save"

@export var world_2d: Node2D
@export var gui: Control

var current_2d_scene: Node2D
var current_gui_scene: Control
var current_chapter: Chapter = Chapter.INTRO
var current_checkpoint: Checkpoint = Checkpoint.START
var is_gameplay: bool = false


## Start the game controller
func _ready() -> void:
	Globals.game_controller = self
	change_gui_scene(SPLASH_SCREEN)
	load_game()


#-- SCENE MANAGER


## Change the 2D scene. Use it for changing levels.
func change_world_2d_scene(
	new_scene_path: String, delete: bool = true, keep_running: bool = false
) -> void:
	# Decide what to do with the current scene
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free()
		elif keep_running:
			current_2d_scene.visible = false
		else:
			world_2d.remove_child(current_2d_scene)

	# Load the new scene
	if (
		new_scene_path == LEVEL_01
		or new_scene_path == LEVEL_02
		or new_scene_path == LEVEL_03
		or new_scene_path == LEVEL_04
		or new_scene_path == CAMERA_TEST
	):
		is_gameplay = true
	else:
		is_gameplay = false

	var new_scene: Node2D = load(new_scene_path).instantiate()
	world_2d.add_child(new_scene)
	current_2d_scene = new_scene

	world_2d_scene_changed.emit(current_2d_scene)


## Change GUI scene. Use it for changing menus
func change_gui_scene(
	new_scene_path: String, delete: bool = true, keep_running: bool = false
) -> void:
	# Decide what to do with the current scene
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)

	# Load the new scene
	var new_scene: Control = load(new_scene_path).instantiate()
	gui.add_child(new_scene)
	current_gui_scene = new_scene

	gui_scene_changed.emit(current_gui_scene)


#-- LEVEL SELECT


func _select_chapter1(checkpoint: Checkpoint) -> String:
	match checkpoint:
		Checkpoint.DIVING:
			return LEVEL_01
		Checkpoint.FOUND:
			return LEVEL_01
		_:
			return POSEIDON_HUB


func _select_chapter2(checkpoint: Checkpoint) -> String:
	match checkpoint:
		Checkpoint.DIVING:
			return LEVEL_02
		Checkpoint.FOUND:
			return LEVEL_02
		_:
			return POSEIDON_HUB


func _select_chapter3(checkpoint: Checkpoint) -> String:
	match checkpoint:
		Checkpoint.DIVING:
			return LEVEL_03
		Checkpoint.FOUND:
			return LEVEL_04
		Checkpoint.START:
			return POSEIDON_HUB
		_:
			return LEVEL_03


func level_select(
	chapter: Chapter = current_chapter, checkpoint: Checkpoint = current_checkpoint
) -> String:
	match chapter:
		Chapter.SAVE001:
			return _select_chapter1(checkpoint)
		Chapter.SAVE002:
			return _select_chapter2(checkpoint)
		Chapter.SAVE003:
			return _select_chapter3(checkpoint)
		_:
			return CAMERA_TEST


#-- PAUSING


func set_paused(is_paused: bool):
	get_tree().paused = is_paused
	pause_state_changed.emit(is_paused)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause") and is_gameplay:
		set_paused(not get_tree().paused)


func _on_pause_state_changed() -> void:
	# TODO: change scene to pause_menu
	return


#-- CHAPTERS AND CHECKPOINT


## Move story forward by one checkpoint
## Can only go forward, not backwards
func progress_story():
	print("Progressing story")
	if current_chapter == Chapter.SAVE003 and current_checkpoint == Checkpoint.FOUND:
		print("sadly")
		return  # end of story

	if current_chapter == Chapter.INTRO and current_checkpoint == Checkpoint.START:
		current_chapter = Chapter.SAVE001
		current_checkpoint = Checkpoint.START
	elif current_checkpoint == Checkpoint.SURFACED:
		if current_chapter == Chapter.SAVE001:
			current_chapter = Chapter.SAVE002
		elif current_chapter == Chapter.SAVE002:
			current_chapter = Chapter.SAVE003
		current_checkpoint = Checkpoint.START
	else:
		if current_checkpoint == Checkpoint.START:
			current_checkpoint = Checkpoint.DIVING
		elif current_checkpoint == Checkpoint.DIVING:
			current_checkpoint = Checkpoint.FOUND
		elif current_checkpoint == Checkpoint.FOUND:
			current_checkpoint = Checkpoint.SURFACED
	print(current_chapter, current_checkpoint)
	story_progressed.emit(current_chapter, current_checkpoint)


#-- SAVE LOAD


func check_save_file_exists():
	return FileAccess.file_exists(SAVE_FILE_PATH)


func _serialize_data():
	return {"chapter": current_chapter, "checkpoint": current_checkpoint}


func save_game():
	game_saving.emit()
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var serialized_data = _serialize_data()
	var json_string = JSON.stringify(serialized_data)
	save_file.store_line(json_string)
	game_saved.emit(serialized_data)


func load_game():
	if not check_save_file_exists():
		return

	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var json_string = save_file.get_line()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print(
			"JSON Parse Error: ",
			json.get_error_message(),
			" in ",
			json_string,
			" at line ",
			json.get_error_line()
		)

	var serialized_data = json.data
	current_checkpoint = serialized_data["checkpoint"]
	current_chapter = serialized_data["chapter"]
	game_loaded.emit(serialized_data)


func _on_story_progressed() -> void:
	save_game()
