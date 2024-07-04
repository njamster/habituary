extends VBoxContainer


func _on_next_day_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(1)


func _on_shift_view_forward_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(Settings.view_mode)


func _input(event: InputEvent) -> void:
	# Necessary workaround since button shortcuts currently don't trigger on mouse events, see:
	# https://github.com/godotengine/godot/issues/90516
	if event.is_action_pressed("shift_view_forward"):
		Utils.press_button_with_visual_feedback($ShiftViewForward)
	elif event.is_action_pressed("next_day"):
		Utils.press_button_with_visual_feedback($NextDay)
