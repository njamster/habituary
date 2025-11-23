extends VBoxContainer


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	_update_button_states()


func _connect_signals() -> void:
	#region Global Signals
	Settings.view_mode_changed.connect(_update_button_states)
	Settings.view_mode_cap_changed.connect(_update_button_states)

	Settings.main_panel_changed.connect(func():
		visible = (Settings.main_panel == Settings.MainPanelState.LIST_VIEW)
	)
	#endregion

	#region Local Signals
	for button in get_children():
		button.pressed.connect(func():
			Settings.view_mode = int(button.text)
		)
	#endregion


func _update_button_states() -> void:
	for button in get_children():
		button.disabled = (int(button.text) > Settings.view_mode_cap)
		if button.disabled:
			button.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		else:
			button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
			button.button_pressed = (int(button.text) == Settings.view_mode)
