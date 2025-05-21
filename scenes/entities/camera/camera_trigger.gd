class_name CameraTrigger

extends Area2D

@export_group("On Enter", "enter_")
@export var enter_enabled: bool = false
@export var enter_mode: GameCamera.CameraMode
@export var enter_limit_top: int = 0
@export var enter_limit_bottom: int = 360
@export var enter_limit_left: int = 0
@export var enter_limit_right: int = 640
@export_custom(PROPERTY_HINT_LINK, "Zoom Ratio") var enter_zoom := Vector2(1, 1)
@export var enter_focus: Vector2i
@export_group("On Leave", "leave_")
@export var leave_enabled: bool = false
@export var leave_mode: GameCamera.CameraMode
@export var leave_limit_top: int = 0
@export var leave_limit_bottom: int = 360
@export var leave_limit_left: int = 0
@export var leave_limit_right: int = 640
@export_custom(PROPERTY_HINT_LINK, "Zoom Ratio") var leave_zoom := Vector2(1, 1)
@export var leave_focus: Vector2i


func _on_body_entered(body: Node2D) -> void:
	if not body is Player or not enter_enabled:
		return
	var current_camera = get_viewport().get_camera_2d()
	if current_camera is GameCamera:
		current_camera.change_camera_mode(enter_mode)
		current_camera.set_camera_limits(
			enter_limit_top, enter_limit_bottom, enter_limit_left, enter_limit_right
		)
		current_camera.set_camera_zoom(enter_zoom)
		current_camera.set_camera_focus(enter_focus)


func _on_body_exited(body: Node2D) -> void:
	if not body is Player or not leave_enabled:
		return
	var current_camera = get_viewport().get_camera_2d()
	if current_camera is GameCamera:
		current_camera.change_camera_mode(leave_mode)
		current_camera.set_camera_limits(
			leave_limit_top, leave_limit_bottom, leave_limit_left, leave_limit_right
		)
		current_camera.set_camera_zoom(leave_zoom)
		current_camera.set_camera_focus(leave_focus)
