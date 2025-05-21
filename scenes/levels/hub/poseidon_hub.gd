extends Node2D

var game_controller: GameController

@onready var player: Player = $Player
@onready var level1_done: Node2D = $Level1Done
@onready var level2_done: Node2D = $Level2Done


func _ready() -> void:
	game_controller = Globals.game_controller
	if game_controller.current_chapter == GameController.Chapter.SAVE001:
		player.position = level1_done.position
	elif game_controller.current_chapter == GameController.Chapter.SAVE002:
		player.position = level2_done.position
