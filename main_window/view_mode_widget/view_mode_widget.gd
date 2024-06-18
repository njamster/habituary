extends HBoxContainer


func _ready() -> void:
	_update_button_state(Settings.view_mode)

	EventBus.view_mode_changed.connect(_update_button_state)

	for button in $Modes.get_children():
		button.pressed.connect(func(): Settings.view_mode = int(button.text))


func _update_button_state(view_mode : int) -> void:
	for button in $Modes.get_children():
		if int(button.text) != view_mode:
			button.flat = true
			button.button_mask = MOUSE_BUTTON_MASK_LEFT
		else:
			button.flat = false
			button.button_mask = 0
