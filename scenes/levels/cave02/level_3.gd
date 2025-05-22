extends Node2D

var game_controller: GameController

@onready var player: Player = $Player
@onready var diving_start_spawn: Node2D = $DivingStart


func _ready() -> void:
	game_controller = Globals.game_controller
	if game_controller.current_checkpoint == GameController.Checkpoint.DIVING:
		player.position = diving_start_spawn.position
		player.animplayer.flip_h = true
