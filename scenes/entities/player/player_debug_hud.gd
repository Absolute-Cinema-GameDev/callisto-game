extends Control

@onready var movementtype_label = $Container/MovementGroup/MovementType
@onready var position_label = $Container/MovementGroup/Position
@onready var velocity_label = $Container/MovementGroup/Velocity
@onready var health_label = $Container/HealthGroup/Health
@onready var invincible_label = $Container/HealthGroup/Invincible
@onready var maintank_label = $Container/OxygenGroup/MainTank
@onready var reservetank_label = $Container/OxygenGroup/ReserveTank
@onready var airpocket_label = $Container/OxygenGroup/AirPocket
@onready var hidden_label = $Container/HealthGroup/Hidden
@onready var stunned_label = $Container/MovementGroup/Stunned
@onready var inputlock_label = $Container/MovementGroup/InputLock


func _ready() -> void:
	var player: Player = get_node("../..")
	movementtype_label.text = ("mv_type: " + str(Player.MovementType.keys()[player.movement_type]))
	position_label.text = (
		"pos: " + str("%0.2f" % player.position.x) + ", " + str("%0.2f" % player.position.y)
	)
	velocity_label.text = (
		"vel: " + str("%0.2f" % player.velocity.x) + ", " + str("%0.2f" % player.velocity.y)
	)
	stunned_label.text = "stun? " + str(player.is_stunned)
	inputlock_label.text = "input_locked? " + str(player.is_input_locked)

	health_label.text = "health_status: " + str(Player.HealthStatus.keys()[player.health_status])
	invincible_label.text = "invincible? " + str(player.is_invincible)
	hidden_label.text = "hidden_enemies? " + str(player.is_hidden_from_enemies)

	maintank_label.text = "main_tank_cap: " + str(player.main_tank_capacity)
	reservetank_label.text = "reserve_tank_cap: " + str(player.reserve_tank_capacity)
	airpocket_label.text = "air_pocket? " + str(player.is_in_airpocket)


func _process(_delta: float) -> void:
	var player: Player = get_node("../..")
	position_label.text = (
		"pos: " + str("%0.2f" % player.position.x) + ", " + str("%0.2f" % player.position.y)
	)
	velocity_label.text = (
		"vel: " + str("%0.2f" % player.velocity.x) + ", " + str("%0.2f" % player.velocity.y)
	)


func _on_player_movement_type_changed(value) -> void:
	movementtype_label.text = "mv_type: " + str(Player.MovementType.keys()[value])


func _on_player_health_changed(value) -> void:
	health_label.text = "health_status: " + str(Player.HealthStatus.keys()[value])


func _on_player_is_invincible_changed(value) -> void:
	invincible_label.text = "invincible? " + str(value)


func _on_player_main_oxygen_changed(value) -> void:
	maintank_label.text = "main_tank_cap: " + str(value)


func _on_player_reserve_oxygen_changed(value) -> void:
	reservetank_label.text = "reserve_tank_cap: " + str(value)


func _on_player_is_in_airpocket_changed(value) -> void:
	airpocket_label.text = "air_pocket? " + str(value)


func _on_player_is_stunned_changed(value) -> void:
	stunned_label.text = "stunned? " + str(value)


func _on_player_is_hidden_from_enemies_changed(value) -> void:
	hidden_label.text = "hidden_enemies? " + str(value)


func _on_player_is_input_locked_changed(value) -> void:
	inputlock_label.text = "input_locked? " + str(value)
