extends Node2D # Or whatever node your Particles2D and Timer are children of


@onready var bubble_particles: GPUParticles2D = $GPUParticles2D
@onready var emission_timer: Timer = $GPUParticles2D/Timer

# Minimum and maximum time for the random interval
@export var min_interval: float = 5.0
@export var max_interval: float = 10.0

func _ready():
	# Connect the timer's timeout signal to a function
	emission_timer.timeout.connect(_on_emission_timer_timeout)
	# Start the first timer with a random interval
	_set_random_timer()

func _set_random_timer():
	# Calculate a random time between min_interval and max_interval
	var random_time = randf_range(min_interval, max_interval)
	emission_timer.wait_time = random_time
	emission_timer.start()
	print("Next bubble emission in: ", random_time, " seconds")

func _on_emission_timer_timeout():
	# Emit the particles
	bubble_particles.emitting = true
	# Since one_shot is true, it will emit once and then stop.
	# We then set the timer for the next emission.
	_set_random_timer()

# Called when a body enters the air pocket
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_is_in_airpocket(true)
# Called when a body exits the air pocket
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.set_is_in_airpocket(false)
