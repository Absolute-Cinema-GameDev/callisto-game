class_name GameCamera

extends Camera2D

signal camera_mode_changed  ## Fires when camera_mode is changed

enum CameraMode { GAMEPLAY, CUTSCENE, NONE }

const TOP_LETTERBOX_SHOWN: Vector2 = Vector2(0, 0)
const TOP_LETTERBOX_HIDDEN: Vector2 = Vector2(0, -44)
const BOTTOM_LETTERBOX_SHOWN: Vector2 = Vector2(0, 316)
const BOTTOM_LETTERBOX_HIDDEN: Vector2 = Vector2(0, 360)
const LETTERBOX_SHOW_TWEEN_DURATION: float = 1
const LETTERBOX_HIDE_TWEEN_DURATION: float = 1

@export var camera_mode: CameraMode = CameraMode.GAMEPLAY

@onready var black_bars: Control = $CanvasLayer/BlackBars
@onready var top_letterbox: TextureRect = $CanvasLayer/BlackBars/TopLetterbox
@onready var bottom_letterbox: TextureRect = $CanvasLayer/BlackBars/BottomLetterbox

#-- CAMERA PROPERTIES


## Set Camera Limits
func set_camera_limits(new_top: int, new_bottom: int, new_left: int, new_right: int):
	limit_top = new_top
	limit_bottom = new_bottom
	limit_left = new_left
	limit_right = new_right


## Set Camera Zoom
func set_camera_zoom(new_zoom: Vector2):
	var zoom_tween := create_tween()
	zoom_tween.stop()
	zoom_tween.set_trans(Tween.TRANS_CUBIC)
	zoom_tween.tween_property(self, "zoom", new_zoom, LETTERBOX_SHOW_TWEEN_DURATION)
	zoom_tween.play()


## Set Camera Focus
func set_camera_focus(new_focus_position: Vector2i):
	position = new_focus_position


#-- CAMERA MODES


func change_camera_mode(new_camera_mode: CameraMode):
	var previous_camera_mode = camera_mode
	if previous_camera_mode == CameraMode.CUTSCENE:
		stop_cutscene()

	camera_mode = new_camera_mode
	if new_camera_mode == CameraMode.CUTSCENE:
		start_cutscene()
	camera_mode_changed.emit(new_camera_mode)


## Start CUTSCENE mode by showing black bars
func start_cutscene():
	var letterbox_show_tween := create_tween()
	letterbox_show_tween.set_trans(Tween.TRANS_CUBIC)
	letterbox_show_tween.tween_property(
		top_letterbox, "position", TOP_LETTERBOX_SHOWN, LETTERBOX_SHOW_TWEEN_DURATION
	)
	letterbox_show_tween.parallel().tween_property(
		bottom_letterbox, "position", BOTTOM_LETTERBOX_SHOWN, LETTERBOX_SHOW_TWEEN_DURATION
	)
	letterbox_show_tween.play()


## Stop CUTSCENE mode by hiding black bars
func stop_cutscene():
	var letterbox_hide_tween := create_tween()
	letterbox_hide_tween.set_trans(Tween.TRANS_CUBIC)
	letterbox_hide_tween.tween_property(
		top_letterbox, "position", TOP_LETTERBOX_HIDDEN, LETTERBOX_HIDE_TWEEN_DURATION
	)
	letterbox_hide_tween.parallel().tween_property(
		bottom_letterbox, "position", BOTTOM_LETTERBOX_HIDDEN, LETTERBOX_HIDE_TWEEN_DURATION
	)
	letterbox_hide_tween.play()


func _ready():
	top_letterbox.visible = true
	bottom_letterbox.visible = true
