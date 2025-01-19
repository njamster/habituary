extends VBoxContainer


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	get_tree().get_root().size_changed.connect(_on_window_size_changed)

	EventBus.view_mode_changed.connect(_on_view_mode_changed)
	_on_view_mode_changed(Settings.view_mode)
	#endregion

	#region Local Signals
	for button in get_children():
		button.pressed.connect(func(): Settings.view_mode = int(button.text))
	#endregion


func _on_window_size_changed() -> void:
	var window_width := DisplayServer.window_get_size().x
	var todolist_width := 160
	var toolbar_width := 28
	var h_spacing := 16

	if window_width >= 2 * toolbar_width + 2 * h_spacing + 7 * todolist_width:
		# all view modes available
		$ThreeDays.disabled = false
		$ThreeDays.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		$FiveDays.disabled = false
		$FiveDays.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		$SevenDays.disabled = false
		$SevenDays.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	elif window_width >= 2 * toolbar_width + 2 * h_spacing + 5 * todolist_width:
		# view mode 7 disabled
		$ThreeDays.disabled = false
		$ThreeDays.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		$FiveDays.disabled = false
		$FiveDays.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		$SevenDays.disabled = true
		$SevenDays.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		if Settings.view_mode > 5:
			Settings.view_mode = 5
	elif window_width >= 2 * toolbar_width + 2 * h_spacing + 3 * todolist_width:
		# view modes 5 & 7 disabled
		$ThreeDays.disabled = false
		$ThreeDays.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		$FiveDays.disabled = true
		$FiveDays.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		$SevenDays.disabled = true
		$SevenDays.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		if Settings.view_mode > 3:
			Settings.view_mode = 3
	elif window_width >= 2 * toolbar_width + 2 * h_spacing + 1 * todolist_width:
		# only view mode 1 available
		$ThreeDays.disabled = true
		$ThreeDays.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		$FiveDays.disabled = true
		$FiveDays.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		$SevenDays.disabled = true
		$SevenDays.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		if Settings.view_mode > 1:
			Settings.view_mode = 1


func _on_view_mode_changed(view_mode : int) -> void:
	for button in get_children():
		button.button_pressed = (int(button.text) == Settings.view_mode)
