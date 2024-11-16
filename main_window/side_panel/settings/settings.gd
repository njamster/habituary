extends VBoxContainer


func _ready() -> void:
	for option_name in Settings.TodayPosition:
		var option_id : int = Settings.TodayPosition[option_name]
		%TodayPosition/Setting/Options.add_item(option_name.capitalize(), option_id)
		if option_id == Settings.today_position:
			%TodayPosition/Setting/Options.select(option_id)

	%FirstWeekday/Setting/Options.button_pressed = Settings.start_week_on_monday

	%DayStart/Setting/Options.value = Settings.day_start_hour_offset


func _on_change_store_path_pressed() -> void:
	OS.shell_show_in_file_manager(Settings.store_path)


func _on_today_position_item_selected(index: int) -> void:
	Settings.today_position = Settings.TodayPosition[Settings.TodayPosition.keys()[index]]

	match index:
		Settings.TodayPosition.LEFTMOST:
			%TodayPosition/Explanation.text = \
				"After changing dates, the currently selected day will be displayed at the leftmost position of the list view."
		Settings.TodayPosition.SECOND_PLACE:
			%TodayPosition/Explanation.text = \
				"After changing dates, the currently selected day will be displayed at the second position of the list view."
		Settings.TodayPosition.CENTERED:
			%TodayPosition/Explanation.text = \
				"After changing dates, the currently selected day will be displayed at the center position of the list view."
		_:
			%TodayPosition/Explanation.text = ""


func _on_first_weekday_toggled(toggled_on: bool) -> void:
	Settings.start_week_on_monday = toggled_on

	if toggled_on:
		%FirstWeekday/Explanation.text = "New weeks in the calendar widget start on Mondays."
	else:
		%FirstWeekday/Explanation.text = "New weeks in the calendar widget start on Sundays."


func _on_day_start_value_changed(value: float) -> void:
	Settings.day_start_hour_offset = int(value)

	%DayStart/Explanation.text = "Today's date will shift one day forward at %02d:00." % value
