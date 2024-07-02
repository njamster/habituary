extends VBoxContainer


func _ready() -> void:
	_on_current_day_changed(Settings.current_day)

	EventBus.current_day_changed.connect(_on_current_day_changed)


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
