extends VBoxContainer


func _ready() -> void:
	EventBus.view_mode_changed.connect(_on_view_mode_changed)


func _on_next_day_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(1)


func _on_shift_view_forward_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(Settings.view_mode)


func _unhandled_input(event: InputEvent) -> void:
	# Necessary workaround since button shortcuts currently don't trigger on mouse events, see:
	# https://github.com/godotengine/godot/issues/90516
	if event.is_action_pressed("shift_view_forward"):
		Utils.press_button_with_visual_feedback($ShiftViewForward)
	elif event.is_action_pressed("next_day"):
		Utils.press_button_with_visual_feedback($NextDay)


func _on_view_mode_changed(view_mode : int) -> void:
	if view_mode == 1:
		$ShiftViewForward/Tooltip.text = "Move %d Day Forward" % view_mode
	else:
		$ShiftViewForward/Tooltip.text = "Move %d Days Forward" % view_mode


func _on_calendar_pressed() -> void:
	EventBus.calendar_button_pressed.emit()
	$Calendar/Tooltip.hide_tooltip()
