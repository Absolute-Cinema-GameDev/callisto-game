extends Node2D
#
#enum AttackPattern { SINGLE, SEQUENTIAL, SIMULTANEOUS }
#
#@export var tentacle_scene: PackedScene
#@export var attack_positions: Array[NodePath] = []
#@export var attack_cooldown: float = 2.0
#@export var attack_interval: float = 0.5  # For sequential attacks
#@export var damage: int = 10
#@export var active: bool = true
#
#var position_nodes: Array = []
#var current_tentacles: Array = []
#var can_attack: bool = true
#var is_attacking: bool = false
#
#func _ready() -> void:
## Get position nodes from paths
#for path in attack_positions:
#var node = get_node(path)
#if node:
#position_nodes.append(node)
#
## Start attack loop if active
#if active:
#attack_loop()
#
#func _process(_delta: float) -> void:
## Optional: Add visual indicators for attack positions during debugging
#pass
#
#func attack_loop() -> void:
#while active:
#if can_attack and not is_attacking:
#perform_random_attack()
#await get_tree().process_frame
#
#func perform_random_attack() -> void:
#if position_nodes.is_empty():
#print("No attack positions defined!")
#return
#
## Choose a random attack pattern
#var pattern = randi() % AttackPattern.size()
#var num_tentacles = randi() % 3 + 1  # Random 1-3 tentacles
#
## Get random attack positions
#var positions = position_nodes.duplicate()
#positions.shuffle()
#positions = positions.slice(0, min(num_tentacles, positions.size() - 1))
#
## Start the attack sequence
#match pattern:
#AttackPattern.SINGLE:
## Just attack with one tentacle
#spawn_and_attack_with_tentacle(positions[0].global_position)
#
#AttackPattern.SEQUENTIAL:
## Attack with multiple tentacles in sequence
#start_sequential_attack(positions)
#
#AttackPattern.SIMULTANEOUS:
## Attack with multiple tentacles at once
#start_simultaneous_attack(positions)
#
#func spawn_tentacle() -> Node:
#var tentacle = tentacle_scene.instantiate()
#add_child(tentacle)
#
## Configure the tentacle
#tentacle.attack_damage = damage
#
## Connect signals
#tentacle.attack_finished.connect(_on_tentacle_attack_finished.bind(tentacle))
#
## Add to tracking array
#current_tentacles.append(tentacle)
#return tentacle
#
#func spawn_and_attack_with_tentacle(position: Vector2) -> void:
#var tentacle = spawn_tentacle()
#
## Start the attack
#tentacle.start_attack(position)
#
## Update states
#is_attacking = true
#can_attack = false
#
#func start_sequential_attack(positions: Array) -> void:
#is_attacking = true
#can_attack = false
#
#for pos in positions:
#spawn_and_attack_with_tentacle(pos.global_position)
#await get_tree().create_timer(attack_interval).timeout
#
#func start_simultaneous_attack(positions: Array) -> void:
#is_attacking = true
#can_attack = false
#
#for pos in positions:
#spawn_and_attack_with_tentacle(pos.global_position)
#
#func _on_tentacle_attack_finished(tentacle) -> void:
## Remove tentacle from tracking array
#current_tentacles.erase(tentacle)
#
## Queue free the tentacle
#tentacle.queue_free()
#
## If no more tentacles, attack is done
#if current_tentacles.is_empty():
#is_attacking = false
#
## Start cooldown
#await get_tree().create_timer(attack_cooldown).timeout
#can_attack = true
#
## Public methods for other scripts to control the manager
#func start_attacks() -> void:
#active = true
#attack_loop()
#
#func stop_attacks() -> void:
#active = false

@onready var stunrock_spawner = $StunrockSpawner
@onready var boss_tentacles = $BossTentacles
@onready var player = $Player

const ROOT_LEVELS_PATH = "res://scenes/levels/"
const POSEIDON_HUB = ROOT_LEVELS_PATH + "hub/poseidon_hub.tscn"  # TODO: adjust sesuai path
const LEVEL_01 = ROOT_LEVELS_PATH + "cave00/level1.tscn"  # TODO: adjust sesuai path
const LEVEL_02 = ROOT_LEVELS_PATH + "cave01/level2.tscn"
const LEVEL_03 = ROOT_LEVELS_PATH + "cave02/level3.tscn"
const LEVEL_04 = ROOT_LEVELS_PATH + "level04/level04.tscn"

const BACKGROUNDS_PATH = ROOT_LEVELS_PATH + "backgrounds/"
const MENU_BACKGROUND = BACKGROUNDS_PATH + "menu_bg.tscn"
const CREDITS_BACKGROUND = BACKGROUNDS_PATH + "credits_bg.tscn"

const ROOT_UI_PATH = "res://scenes/ui/"
const SPLASH_SCREEN = ROOT_UI_PATH + "splash_screen/splash_screen.tscn"  # TODO: adjust sesuai path
const TITLE_SCREEN = ROOT_UI_PATH + "title_screen/title_screen.tscn"
const PAUSE_MENU = ROOT_UI_PATH + "pause_menu/pause_menu.tscn"
const HUD = ROOT_UI_PATH + "hud/hud.tscn"
const NEW_GAME_WARNING = ROOT_UI_PATH + "new_game_warning_screen/new_game_warning_screen.tscn"
const CREDITS_SCREEN = ROOT_UI_PATH + "credits_screen/scredits_screen.tscn"

const CUT_SCENE = ROOT_LEVELS_PATH + "level04/final_cutscene.tscn"

var _survival_timer = null
var _intense_timer = null

var survival_time = 10.0
var intense_time = 10.0

var _phase := "survival"
var cutscene: String = "res://scenes/levels/" # Placeholder for next scene path
var _pending_respawn := false

func _ready():
	# Start with normal phase
	_phase = "survival"
	_survival_timer = get_tree().create_timer(survival_time)
	_survival_timer.timeout.connect(_on_survival_phase_end)
	# Connect to player death (health_status change)
	if is_instance_valid(player):
		player.connect("main_oxygen_changed", _on_player_health_changed)
		player.connect("reserve_oxygen_changed", _on_player_health_changed)
	# If respawned, play fade_out
	if _pending_respawn:
		var transition_scene = preload("res://scenes/ui/scene_transition/Scenetransition.tscn").instantiate()
		get_tree().current_scene.add_child(transition_scene)
		var anim_player = transition_scene.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.play("fade_out")
		_pending_respawn = false

func _on_player_health_changed(_value):
	# Only respawn if not in intense or done phase
	if _phase != "survival":
		return
	if player.get_health_status() == player.HealthStatus.DEAD:
		# Play fade_in, then reload scene and play fade_out
		var transition_scene = preload("res://scenes/ui/scene_transition/Scenetransition.tscn").instantiate()
		get_tree().current_scene.add_child(transition_scene)
		var anim_player = transition_scene.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.play("fade_in")
			anim_player.animation_finished.connect(_on_fade_in_for_respawn)

func _on_fade_in_for_respawn(_anim_name):
	# Mark respawn so fade_out is played on reload
	_pending_respawn = true
	get_tree().reload_current_scene()

func _on_survival_phase_end():
	_phase = "intense"
	# Set stunrock spawner to spawn every 1s
	if is_instance_valid(stunrock_spawner):
		stunrock_spawner.min_spawn_interval = 1.0
		stunrock_spawner.max_spawn_interval = 1.0
	# Set tentacles to attack all 3 at once, continuously
	if is_instance_valid(boss_tentacles):
		boss_tentacles.min_attack_interval = 0.0
		boss_tentacles.max_attack_interval = 0.0
		boss_tentacles.attack_pattern_chance = 1.0 # Always pick 2, but force all 3 below
		if boss_tentacles.has_method("force_all_tentacles_next_attack"):
			boss_tentacles.force_all_tentacles_next_attack()
	_intense_timer = get_tree().create_timer(intense_time)
	_intense_timer.timeout.connect(_on_intense_phase_end)

func _on_intense_phase_end():
	_phase = "done"
	# Stop stunrock spawner and tentacle attacks
	if is_instance_valid(stunrock_spawner):
		stunrock_spawner.min_spawn_interval = 9999
		stunrock_spawner.max_spawn_interval = 9999
	if is_instance_valid(boss_tentacles):
		boss_tentacles.min_attack_interval = 9999
		boss_tentacles.max_attack_interval = 9999
	# Play fade out animation from Scenetransition
	var transition_scene = preload("res://scenes/ui/scene_transition/Scenetransition.tscn").instantiate()
	get_tree().current_scene.add_child(transition_scene)
	var anim_player = transition_scene.get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.play("fade_in")
		anim_player.animation_finished.connect(_on_fade_out_finished)

func _on_fade_out_finished(_anim_name):
	# Placeholder: change to cutscene or pause
	# get_tree().paused = true
	# To change scene later: 
	get_tree().change_scene_to_file(CUT_SCENE)
