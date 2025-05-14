class_name EnemyStateIdle extends EnemyState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min : float = 0.5
@export var state_duration_max : float = 1.5
@export var after_idle_state : EnemyStateWander

var timer : float = 0.0

## What happend when we initialize this State
func init() -> void:
	pass

## What happens when the enemy enter this State
func enter() -> void:
	enemy.velocity = Vector2.ZERO
	timer = randf_range(state_duration_min, state_duration_max)
	enemy.update_animation(anim_name)
	pass
	
## What happens when the enemy exit this State
func exit() -> void:
	pass
	
## What happens during the _process update in this State
func process(delta : float) -> EnemyState:
	timer -= delta
	if timer <= 0:
		return after_idle_state
	return null

## What happens during the _physics_process update in this State
func physics(delta : float) -> EnemyState:
	return null
