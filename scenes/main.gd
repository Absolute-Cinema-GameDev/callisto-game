class_name GameController

extends Node

enum Chapter { INTRO, SAVE001, SAVE002, SAVE003 }
enum Checkpoint { START, DIVING, SURFACE }

const LEVELS_PATH = "res://scenes/levels/"
const BACKGROUNDS_PATH = "backgrounds/"
const LEVEL_001 = ""
const LEVEL_002 = ""
const LEVEL_003 = ""
const LEVEL_004 = ""

@export var world_2d: Node2D
@export var gui: Control

var game_controller: GameController
var current_2d_scene: Node2D
var current_gui_scene: Control

var current_chapter: Chapter = Chapter.INTRO
var current_checkpoint: Checkpoint = Checkpoint.START
var save_file_path = "user://save"
var save_file_name = "004.save"


## Start the game controller
func _ready() -> void:
	Game.game_controller = self


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
	var new_scene = load(new_scene_path).instantiate()
	world_2d.add_child(new_scene)
	current_2d_scene = new_scene


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
	var new_scene = load(new_scene_path).instantiate()
	gui.add_child(new_scene)
	current_gui_scene = new_scene


#-- SAVE LOAD


func _check_save_file_exists():
	return FileAccess.file_exists(save_file_path + save_file_name)


func _serialize_data():
	return {"chapter": current_chapter, "checkpoint": current_checkpoint}


func save_game():
	var save_file = FileAccess.open(save_file_path + save_file_name, FileAccess.WRITE)
	var serialized_data = _serialize_data()
	var json_string = JSON.stringify(serialized_data)
	save_file.store_line(json_string)


func load_game():
	if not _check_save_file_exists():
		return

	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
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
