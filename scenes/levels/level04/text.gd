extends Label

var full_text = ""
var char_index = 0
var typing_speed = 0.05
var deleting_speed = 0.03
var typing_timer = 0.0
var deleting = false
var has_finished_typing = false

func start_typing(text_to_type: String) -> void:
	full_text = text_to_type
	char_index = 0
	text = ""
	typing_timer = 0.0
	deleting = false
	has_finished_typing = false
	set_process(true)

func start_deleting() -> void:
	deleting = true
	typing_timer = 0.0
	set_process(true)

func _process(delta):
	typing_timer += delta
	if not deleting:
		if char_index < full_text.length():
			if typing_timer >= typing_speed:
				typing_timer = 0
				char_index += 1
				text = full_text.substr(0, char_index)
		elif not has_finished_typing:
			has_finished_typing = true
	else:
		if char_index > 0:
			if typing_timer >= deleting_speed:
				typing_timer = 0
				char_index -= 1
				text = full_text.substr(0, char_index)
		else:
			set_process(false)
