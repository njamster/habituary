extends VBoxContainer


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	EventBus.view_mode_changed.connect(_on_view_mode_changed)

	EventBus.current_day_changed.connect(_on_current_day_changed)
	_on_current_day_changed(Settings.current_day)
	#endregion

	#region Local Signals
	$PreviousDay.pressed.connect(_on_previous_day_pressed)

	$ShiftViewBackward.pressed.connect(_on_shift_view_backward_pressed)

	$Today.pressed.connect(_on_today_pressed)
	#endregion


func _on_previous_day_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(-1)


func _on_shift_view_backward_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(-Settings.view_mode)


func _on_today_pressed() -> void:
	Settings.current_day = DayTimer.today


func _on_current_day_changed(current_day : Date) -> void:
	if current_day.day_difference_to(DayTimer.today) == 0:
		$Today.disabled = true
		$Today.mouse_default_cursor_shape = CURSOR_FORBIDDEN
	else:
		$Today.disabled = false
		$Today.mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _on_view_mode_changed(view_mode : int) -> void:
	if view_mode == 1:
		$ShiftViewBackward/Tooltip.text = "Move %d Day Back" % view_mode
	else:
		$ShiftViewBackward/Tooltip.text = "Move %d Days Back" % view_mode
