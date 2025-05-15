extends Control

@onready var movementtype_label = $Container/MovementGroup/MovementType
@onready var velocity_label = $Container/MovementGroup/Velocity
@onready var health_label = $Container/HealthGroup/Health
@onready var invincible_label = $Container/HealthGroup/Invincible
@onready var maintank_label = $Container/OxygenGroup/MainTank
@onready var reservetank_label = $Container/OxygenGroup/ReserveTank
@onready var airpocket_label = $Container/OxygenGroup/AirPocket


func _ready() -> void:
	var player: Player = get_node("../..")
	movementtype_label.text = (
		"Movement Type: " + str(Player.MovementType.keys()[player.movement_type])
	)
	velocity_label.text = (
		"Velocity: " + str("%0.2f" % player.velocity.x) + ", " + str("%0.2f" % player.velocity.y)
	)

	health_label.text = "Health: " + str(Player.HealthStatus.keys()[player.health_status])
	invincible_label.text = "Is Invincible? " + str(player.is_invincible)

	maintank_label.text = "Main Tank: " + str(player.main_tank_capacity)
	reservetank_label.text = "Reserve Tank: " + str(player.reserve_tank_capacity)
	airpocket_label.text = "Is In Air Pocket? " + str(player.is_in_airpocket)


func _process(_delta: float) -> void:
	var player: Player = get_node("../..")
	velocity_label.text = (
		"Velocity: " + str("%0.2f" % player.velocity.x) + ", " + str("%0.2f" % player.velocity.y)
	)


func _on_player_movement_type_changed(value) -> void:
	movementtype_label.text = "Movement Type: " + str(Player.MovementType.keys()[value])


func _on_player_health_changed(value) -> void:
	health_label.text = "Health: " + str(Player.HealthStatus.keys()[value])


func _on_player_is_invincible_changed(value) -> void:
	invincible_label.text = "Is Invincible? " + str(value)


func _on_player_main_oxygen_changed(value) -> void:
	maintank_label.text = "Main Tank: " + str(value)


func _on_player_reserve_oxygen_changed(value) -> void:
	reservetank_label.text = "Reserve Tank: " + str(value)


func _on_player_is_in_airpocket_changed(value) -> void:
	airpocket_label.text = "Is In Air Pocket? " + str(value)
