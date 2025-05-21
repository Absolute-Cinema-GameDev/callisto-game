class_name LevelObjective

extends Node2D

@export_group("Requirement", "required_")
@export var required_chapter: GameController.Chapter
@export var required_checkpoint: GameController.Checkpoint

var game_controller: GameController


func _ready() -> void:
	game_controller = Globals.game_controller


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	if (
		game_controller.current_chapter == required_chapter
		and game_controller.current_checkpoint == required_checkpoint
	):
		game_controller.progress_story()
