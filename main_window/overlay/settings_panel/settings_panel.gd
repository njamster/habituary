extends PanelContainer


func _enter_tree() -> void:
	# See: https://github.com/godotengine/godot/issues/83546#issuecomment-1856927502
	# Without this line (or a custom_minimum_size for the label), the autowrapping will blow up the
	# vertical size of the panel. This can (as of now) only be done via code, not in the editor.
	$VBox/VBox1/Explanation.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)


func _ready() -> void:
	var app_version : String = ProjectSettings.get("application/config/version")
	if app_version:
		$VBox/VBox/Version/ID.text = app_version
	else:
		$VBox/VBox/Version.queue_free()

	%StorePath/Path.text = Settings.store_path

	for option_name in Settings.TodayPosition:
		var option_id : int = Settings.TodayPosition[option_name]
		%TodayPosition/Options.add_item(option_name.capitalize(), option_id)
		if option_id == Settings.today_position:
			%TodayPosition/Options.select(option_id)
			_on_options_item_selected(option_id)
#
	%FirstWeekday/Options.button_pressed = Settings.start_week_on_monday
	_on_options_toggled(Settings.start_week_on_monday)

	%DayStartsAt/Options.value = Settings.day_start_hour_offset
	_on_options_value_changed(Settings.day_start_hour_offset)


func _on_visibility_changed() -> void:
	if visible:
		%Close.grab_focus()


func _on_options_item_selected(index: int) -> void:
	Settings.today_position = Settings.TodayPosition[Settings.TodayPosition.keys()[index]]
	match index:
		Settings.TodayPosition.LEFTMOST:
			%TodayPosition.get_node("../Explanation").text = \
				"The current day will be displayed at the leftmost position of the list view."
		Settings.TodayPosition.SECOND_PLACE:
			%TodayPosition.get_node("../Explanation").text = \
				"The current day will be displayed at the second position of the list view."
		Settings.TodayPosition.CENTERED:
			%TodayPosition.get_node("../Explanation").text = \
				"The current day will be displayed at the center position of the list view."
		_:
			%TodayPosition.get_node("../Explanation").text = ""


func _on_options_toggled(toggled_on: bool) -> void:
	Settings.start_week_on_monday = toggled_on
	if toggled_on:
		%FirstWeekday.get_node("../Explanation").text = "New weeks in the calendar widget will start on Mondays."
	else:
		%FirstWeekday.get_node("../Explanation").text = "New weeks in the calendar widget will start on Sundays."


func _on_options_value_changed(value: int) -> void:
	Settings.day_start_hour_offset = value
	%DayStartsAt.get_node("../Explanation").text = \
		"Today's date will shift one day forward at %02d:00." % value


func _on_close_pressed() -> void:
	get_parent().close_overlay()
