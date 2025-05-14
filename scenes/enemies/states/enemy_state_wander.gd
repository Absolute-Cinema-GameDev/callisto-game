class_name EnemyStateWander extends EnemyState

@export var anim_name : String = "walk"
@export var walk_speed : float = 20.0

@export_category("AI")
@export var state_animation_duration : float = 3
@export var state_cycle_min : int = 1
@export var state_cycle_max : int = 3
@export var next_state : EnemyStateIdle

var timer : float = 0.0
var direction : Vector2

## What happend when we initialize this State
func init() -> void:
	pass

## What happens when the enemy enter this State
func enter() -> void:
	timer = randi_range(state_cycle_min, state_cycle_max) * state_animation_duration
	var rand = randi_range(0, 3)
	direction = enemy.DIR_4[rand]
	enemy.velocity = direction * walk_speed
	enemy.set_direction(direction)
	enemy.update_animation(anim_name)
	pass
	
## What happens when the enemy exit this State
func exit() -> void:
	pass
	
## What happens during the _process update in this State
func process(delta : float) -> EnemyState:
	timer -= delta
	if timer < 0:
		return next_state
	return null

## What happens during the _physics_process update in this State
func physics(delta : float) -> EnemyState:
	return null
