class_name EnemyState extends Node


## Store a reference to the enemy that this State belongs to
var enemy : Enemy
var state_machine : EnemyStateMachine

## What happend when we initialize this State
func init() -> void:
	pass

## What happens when the enemy enter this State
func enter() -> void:
	pass
	
## What happens when the enemy exit this State
func exit() -> void:
	pass
	
## What happens during the _process update in this State
func process(delta : float) -> EnemyState:
	return null

## What happens during the _physics_process update in this State
func physics(delta : float) -> EnemyState:
	return null
