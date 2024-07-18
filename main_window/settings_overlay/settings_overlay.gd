extends CanvasLayer

var previous_min_size : Vector2i


func _ready() -> void:
	self.hide()

	EventBus.settings_button_pressed.connect(open_settings)


func open_settings() -> void:
	%StorePath/Path.text = Settings.store_path

	%TodayPosition/Options.clear()
	for option_name in Settings.TodayPosition:
		var option_id : int = Settings.TodayPosition[option_name]
		%TodayPosition/Options.add_item(option_name.capitalize(), option_id)
		if option_id == Settings.today_position:
			%TodayPosition/Options.select(option_id)
			_on_options_item_selected(option_id)

	self.show()
	%Close.grab_focus()

	previous_min_size = DisplayServer.window_get_min_size()
	DisplayServer.window_set_min_size(Vector2i(
		max($SettingsPanel.size.x, previous_min_size.x),
		max($SettingsPanel.size.y, previous_min_size.y)
	))


func close_settings() -> void:
	self.hide()

	if previous_min_size:
		# FIXME: re-triggering the min_size calculation of the MainWindow would probably be cleaner
		DisplayServer.window_set_min_size(previous_min_size)


func _on_dimmed_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		close_settings()


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


func _on_close_pressed() -> void:
	close_settings()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_settings()
