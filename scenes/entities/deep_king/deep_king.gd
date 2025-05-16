extends CharacterBody2D

enum AttackType {TOP, MIDDLE, BOTTOM, TOP_MIDDLE, MIDDLE_BOTTOM, TOP_BOTTOM}

@export var attack_cooldown: float = 2.0
@export var attack_duration: float = 1.0
@export var damage: int = 10

# Attack areas
@onready var attack_top = $AttackTopArea/AttackTop
@onready var attack_middle = $AttackMiddleArea/AttackMiddle
@onready var attack_bottom = $AttackBottomArea/AttackBottom

# For tracking states
var can_attack: bool = true
var current_attack_areas = []
var is_attacking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Disable all attack collision shapes initially
	attack_top.disabled = true
	attack_middle.disabled = true
	attack_bottom.disabled = true

	# Connect area signals
	$AttackTopArea.body_entered.connect(_on_attack_area_body_entered)
	$AttackMiddleArea.body_entered.connect(_on_attack_area_body_entered)
	$AttackBottomArea.body_entered.connect(_on_attack_area_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_attack and not is_attacking:
		perform_random_attack()

func perform_random_attack() -> void:
	# Choose a random attack pattern
	var attack_type = randi() % AttackType.size()
	
	# Start the attack sequence
	match attack_type:
		AttackType.TOP:
			start_attack([attack_top])
		AttackType.MIDDLE:
			start_attack([attack_middle])
		AttackType.BOTTOM:
			start_attack([attack_bottom])
		AttackType.TOP_MIDDLE:
			start_attack([attack_top, attack_middle])
		AttackType.MIDDLE_BOTTOM:
			start_attack([attack_middle, attack_bottom])
		AttackType.TOP_BOTTOM:
			start_attack([attack_top, attack_bottom])

func start_attack(attack_areas: Array) -> void:
	# Store the current attack areas
	current_attack_areas = attack_areas
	is_attacking = true
	can_attack = false
	
	# Visual warning (optional - you can add animation or visual effect here)
	print("Boss is preparing an attack!")
	
	# Wait a moment before actually attacking (telegraph the attack)
	await get_tree().create_timer(1.0).timeout
	
	# Activate the attack areas
	for area in current_attack_areas:
		area.disabled = false
	
	# End the attack after duration
	await get_tree().create_timer(attack_duration).timeout
	end_attack()
	
	# Start cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func end_attack() -> void:
	# Disable all attack areas
	for area in current_attack_areas:
		area.disabled = true
	
	is_attacking = false
	current_attack_areas = []

func _on_attack_area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
