extends VBoxContainer


func _ready() -> void:
	_on_current_day_changed(Settings.current_day)

	EventBus.view_mode_changed.connect(_on_view_mode_changed)
	EventBus.current_day_changed.connect(_on_current_day_changed)


func _on_previous_day_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(-1)


func _on_shift_view_backward_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(-Settings.view_mode)


func _on_today_pressed() -> void:
	Settings.current_day = DayTimer.today


func _on_current_day_changed(current_day : Date) -> void:
	$Today.visible = (current_day.day_difference_to(DayTimer.today) != 0)


func _unhandled_input(event: InputEvent) -> void:
	# Necessary workaround since button shortcuts currently don't trigger on mouse events, see:
	# https://github.com/godotengine/godot/issues/90516
	if event.is_action_pressed("shift_view_backward"):
		Utils.press_button_with_visual_feedback($ShiftViewBackward)
	elif event.is_action_pressed("previous_day"):
		Utils.press_button_with_visual_feedback($PreviousDay)


func _on_view_mode_changed(view_mode : int) -> void:
	if view_mode == 1:
		$ShiftViewBackward/Tooltip.text = "Move %d Day Back" % view_mode
	else:
		$ShiftViewBackward/Tooltip.text = "Move %d Days Back" % view_mode
