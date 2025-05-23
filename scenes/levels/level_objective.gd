class_name LevelObjective

extends Node2D

@export_group("Requirement", "required_")
@export var required_chapter: GameController.Chapter
@export var required_checkpoint: GameController.Checkpoint

var game_controller: GameController

@onready var scene_transition_animation: AnimationPlayer = get_parent().get_node(
	"Scenetransition/AnimationPlayer"
)


func _ready() -> void:
	game_controller = Globals.game_controller
	scene_transition_animation.play("fade_out")


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	if (
		game_controller.current_chapter == required_chapter
		and game_controller.current_checkpoint == required_checkpoint
	):
		game_controller.progress_story()