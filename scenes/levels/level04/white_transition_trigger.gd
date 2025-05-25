extends Area2D

@onready var anim: AnimationPlayer = get_parent().get_node("AnimationPlayer")
@onready var color_rect = get_parent().get_node("WhiteOverlay")


func _ready():
	anim.animation_finished.connect(_on_animation_finished)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("enter")
		color_rect.visible = true
		anim.play("fade_to_white")


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_to_white":
		get_tree().change_scene_to_file("res://scenes/main.tscn")
