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
	body.set_is_input_locked(true)
	await get_tree().create_timer(3).timeout
	scene_transition_animation.play("fade_in")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/levels/boss_level/boss_level_scene.tscn")
