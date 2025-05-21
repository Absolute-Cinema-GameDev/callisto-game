extends MenuScreen

const HUD_ITEM_FADE_IN_TIME = 0.5
const HUD_ITEM_FADE_OUT_TIME = 0.5
const QUEST_LOG_UPDATE_TIME = 1
const QUEST_LOG_UPDATE_HANG_TIME = 4
const QUEST_LOG_HANG_TIME = 10
const SAVE_STATUS_HANG_TIME = 3
const QUEST_LOG_LABEL_UPDATE_TIME = 0.5

const ROOT_HUD_ASSETS_PATH = "res://assets/ui/hud/"

const OXYGEN_MAIN_FULL = ROOT_HUD_ASSETS_PATH + "oxygen_main_full.png"
const OXYGEN_MAIN_HALF = ROOT_HUD_ASSETS_PATH + "oxygen_main_half.png"
const OXYGEN_RESERVE_FULL = ROOT_HUD_ASSETS_PATH + "oxygen_reserve_full.png"
const OXYGEN_RESERVE_HALF = ROOT_HUD_ASSETS_PATH + "oxygen_main_half.png"

const OXYGEN_EMPTY = ROOT_HUD_ASSETS_PATH + "oxygen_main_empty.png"
const CHECKBOX_EMPTY = ROOT_HUD_ASSETS_PATH + "checkbox_empty.png"
const CHECKBOX_CHECKED = ROOT_HUD_ASSETS_PATH + "checkbox_checked.png"
const QUEST_FINISHED_COLOR = Color(1, 0.875, 0, 1)

const PRELOADED_ASSETS = {
	"oxygen_main_full": preload(OXYGEN_MAIN_FULL),
	"oxygen_main_half": preload(OXYGEN_MAIN_HALF),
	"oxygen_reserve_full": preload(OXYGEN_RESERVE_FULL),
	"oxygen_reserve_half": preload(OXYGEN_RESERVE_HALF),
	"oxygen_empty": preload(OXYGEN_EMPTY),
	"checkbox_empty": preload(CHECKBOX_EMPTY),
	"checkbox_checked": preload(CHECKBOX_CHECKED)
}

const QUEST_LOG_STRINGS = {
	"intro": "Investigate the area",
	"complete": "Report to Poseidon-1 Station Hub",
	"save001": "Find Crew Member 001",
	"save002": "Find Crew Member 002",
	"save003": "Find Crew Member 003",
	"save004": "Survive",
}

@onready var quest_log = $Layout/TopLeft/QuestLog
@onready var quest_log_icon = $Layout/TopLeft/QuestLog/Icon
@onready var quest_log_label = $Layout/TopLeft/QuestLog/Label

@onready var main_tank = $Layout/TopRight/MainTank
@onready var main_tank_bar = $Layout/TopRight/MainTank/Bar
@onready var main_tank_label = $Layout/TopRight/MainTank/Label

@onready var reserve_tank = $Layout/TopRight/ReserveTank
@onready var reserve_tank_bar = $Layout/TopRight/ReserveTank/Bar
@onready var reserve_tank_label = $Layout/TopRight/ReserveTank/Label

@onready var save_status_label = $Layout/BottomRight/SaveStatusLabel


func _ready() -> void:
	self.game_controller = Globals.game_controller

	# 1. Hook signal from game_controller -> game_saved
	game_controller.game_saving.connect(update_save_status_label_saving)
	game_controller.game_saved.connect(update_save_status_label_saved)

	game_controller.story_progressed.connect(_on_story_progress)

	# 3. Hook player changed signal ASAP
	if Globals.current_player != null:
		Globals.current_player.main_oxygen_changed.connect(update_main_tank)
		Globals.current_player.reserve_oxygen_changed.connect(update_reserve_tank)
		Globals.current_player.movement_type_changed.connect(_on_movement_type_changed)
	else:
		Globals.player_changed.connect(_hook_player_events)

	# Update HUD with latest data
	_update_all_hud_item()


func _hook_player_events(player: Player) -> void:
	player.main_oxygen_changed.connect(update_main_tank)
	player.reserve_oxygen_changed.connect(update_reserve_tank)
	player.movement_type_changed.connect(_on_movement_type_changed)
	update_main_tank(int(player.main_tank_capacity))
	update_reserve_tank(int(player.reserve_tank_capacity))
	_on_movement_type_changed(player.get_movement_type())


func _update_all_hud_item() -> void:
	if Globals.current_player != null:
		_on_movement_type_changed(Globals.current_player.get_movement_type())
		# 1. main_tank
		update_main_tank(int(Globals.current_player.main_tank_capacity))
		# 2. reserve_tank
		update_reserve_tank(int(Globals.current_player.reserve_tank_capacity))
	# 3. quest log
	update_quest_log(_get_current_quest_log_string(), false)
	# 4. save
	hide_hud_item(save_status_label)


func _select_chapter1(
	checkpoint: GameController.Checkpoint = game_controller.current_checkpoint
) -> String:
	match checkpoint:
		GameController.Checkpoint.FOUND:
			return QUEST_LOG_STRINGS["complete"]
		GameController.Checkpoint.SURFACED:
			return QUEST_LOG_STRINGS["complete"]
		_:
			return QUEST_LOG_STRINGS["save001"]


func _select_chapter2(
	checkpoint: GameController.Checkpoint = game_controller.current_checkpoint
) -> String:
	match checkpoint:
		GameController.Checkpoint.FOUND:
			return QUEST_LOG_STRINGS["complete"]
		GameController.Checkpoint.SURFACED:
			return QUEST_LOG_STRINGS["complete"]
		_:
			return QUEST_LOG_STRINGS["save002"]


func _select_chapter3(
	checkpoint: GameController.Checkpoint = game_controller.current_checkpoint
) -> String:
	match checkpoint:
		GameController.Checkpoint.FOUND:
			return QUEST_LOG_STRINGS["save004"]
		_:
			return QUEST_LOG_STRINGS["save003"]


func _get_current_quest_log_string(
	chapter: GameController.Chapter = game_controller.current_chapter,
	checkpoint: GameController.Checkpoint = game_controller.current_checkpoint
) -> String:
	match chapter:
		GameController.Chapter.INTRO:
			return QUEST_LOG_STRINGS["intro"]
		GameController.Chapter.SAVE001:
			return _select_chapter1(checkpoint)
		GameController.Chapter.SAVE002:
			return _select_chapter2(checkpoint)
		GameController.Chapter.SAVE003:
			return _select_chapter2(checkpoint)
		_:
			return QUEST_LOG_STRINGS["intro"]


#-- SHOW/HIDE HUD ITEM


func show_hud_item(hud_item: Control) -> void:
	var fadein = create_tween()
	fadein.stop()
	(
		fadein
		. tween_property(hud_item, "modulate", Color(SHOWN_COLOR), HUD_ITEM_FADE_IN_TIME)
		. from(HIDDEN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	fadein.play()
	await fadein.finished


func hide_hud_item(hud_item: Control) -> void:
	var fadeout = create_tween()
	fadeout.stop()
	(
		fadeout
		. tween_property(hud_item, "modulate", Color(HIDDEN_COLOR), HUD_ITEM_FADE_OUT_TIME)
		. from(SHOWN_COLOR)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	fadeout.play()
	await fadeout.finished


# Quest Log animations
func animate_quest_log_finished() -> void:
	var become_golden = create_tween()
	become_golden.stop()
	(
		become_golden
		. tween_property(quest_log, "modulate", QUEST_FINISHED_COLOR, QUEST_LOG_UPDATE_TIME)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	become_golden.play()
	await become_golden.finished


func animate_quest_log_unfinished() -> void:
	var become_white = create_tween()
	become_white.stop()
	(
		become_white
		. tween_property(quest_log, "modulate", SHOWN_COLOR, QUEST_LOG_UPDATE_TIME)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	become_white.play()
	await become_white.finished


func animate_quest_log_update_label(new_label_text: String) -> void:
	var fadeout = create_tween()
	fadeout.stop()
	(
		fadeout
		. tween_property(quest_log_label, "modulate", HIDDEN_COLOR, QUEST_LOG_LABEL_UPDATE_TIME)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	fadeout.play()
	await fadeout.finished
	quest_log_label.text = new_label_text
	var fadein = create_tween()
	fadein.stop()
	(
		fadein
		. tween_property(quest_log_label, "modulate", SHOWN_COLOR, QUEST_LOG_LABEL_UPDATE_TIME)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	fadein.play()
	await fadein.finished


#-- UPDATE HUD ITEM


func update_save_status_label_saving():
	save_status_label.text = "Saving..."
	show_hud_item(save_status_label)


func update_save_status_label_saved(_serialized_data: Dictionary):
	save_status_label.text = "Saved"
	await get_tree().create_timer(SAVE_STATUS_HANG_TIME).timeout
	hide_hud_item(save_status_label)


func _calculate_oxygen_bar(new_capacity: int, max_capacity: int) -> Dictionary:
	@warning_ignore("integer_division")
	var full_bubbles: int = new_capacity / 10

	@warning_ignore("integer_division")
	var max_bubbles: int = max_capacity / 10
	var has_half_bubble: bool = new_capacity % 10 <= 5
	var last_oxygen_filled: bool = new_capacity % 10 > 0
	return {
		"full_bubbles": full_bubbles,
		"max_bubbles": max_bubbles,
		"has_half_bubble": has_half_bubble,
		"last_oxygen_filled": last_oxygen_filled
	}


func _update_oxygen_bar(bar: Control, bar_data: Dictionary, new_capacity: int) -> void:
	var full_bubbles = bar_data["full_bubbles"]
	var max_bubbles = bar_data["max_bubbles"]
	var has_half_bubble = bar_data["has_half_bubble"]
	var last_oxygen_filled = bar_data["last_oxygen_filled"]

	var oxygen_full_texture = PRELOADED_ASSETS["oxygen_main_full"]
	var oxygen_half_texture = PRELOADED_ASSETS["oxygen_main_half"]
	if bar == reserve_tank_bar:
		oxygen_full_texture = PRELOADED_ASSETS["oxygen_reserve_full"]
		oxygen_half_texture = PRELOADED_ASSETS["oxygen_reserve_half"]
	var oxygen_empty_texture = PRELOADED_ASSETS["oxygen_empty"]

	if new_capacity > 0:
		# set these as full bubbles
		for i in range(0, full_bubbles):
			bar.get_child(i).texture = oxygen_full_texture
		if last_oxygen_filled:
			if has_half_bubble:
				bar.get_child(full_bubbles).texture = oxygen_half_texture
			else:
				bar.get_child(full_bubbles).texture = oxygen_full_texture
	# set the rest as fully unhealed bubbles
	if last_oxygen_filled:
		full_bubbles += 1  # skip last half bubble if exists
	for i in range(full_bubbles, max_bubbles):
		bar.get_child(i).texture = oxygen_empty_texture


func _on_movement_type_changed(new_movement_type: Player.MovementType):
	if new_movement_type == Player.MovementType.WALK:
		main_tank.hide()
		reserve_tank.hide()
	elif new_movement_type == Player.MovementType.SWIM:
		main_tank.show()
		reserve_tank.show()


func update_main_tank(new_capacity: int) -> void:
	var bar_data = _calculate_oxygen_bar(int(new_capacity), int(Player.MAX_OXYGEN_MAIN))
	_update_oxygen_bar(main_tank_bar, bar_data, new_capacity)


func update_reserve_tank(new_capacity: int) -> void:
	var bar_data = _calculate_oxygen_bar(int(new_capacity), int(Player.MAX_OXYGEN_RESERVE))
	_update_oxygen_bar(reserve_tank_bar, bar_data, new_capacity)


func update_quest_log(new_quest: String, prev_complete: bool = true) -> void:
	if quest_log.modulate.a < 1:
		await show_hud_item(quest_log)

	# mark previous quest as complete
	if prev_complete:
		quest_log_icon.texture = PRELOADED_ASSETS["checkbox_checked"]
		await animate_quest_log_finished()
		await get_tree().create_timer(QUEST_LOG_UPDATE_HANG_TIME).timeout

	# reset quest log to incomplete
	quest_log_icon.texture = PRELOADED_ASSETS["checkbox_empty"]
	quest_log_label.text = new_quest
	if prev_complete:
		await animate_quest_log_unfinished()

	# wait for a bit so the user can read
	await get_tree().create_timer(QUEST_LOG_HANG_TIME).timeout
	hide_hud_item(quest_log)


func _on_story_progress(
	chapter: GameController.Chapter, checkpoint: GameController.Checkpoint
) -> void:
	update_quest_log(_get_current_quest_log_string(chapter, checkpoint))
