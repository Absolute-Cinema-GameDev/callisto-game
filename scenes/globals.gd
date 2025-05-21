extends Node

signal player_changed

var game_controller: GameController
var current_player: Player


func change_current_player(player: Player) -> void:
	current_player = player
	player_changed.emit(current_player)
