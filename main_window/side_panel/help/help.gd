extends VBoxContainer


func _ready() -> void:
	var app_version : String = ProjectSettings.get("application/config/version")
	if app_version:
		%Version/ID.text = app_version
	else:
		%Version.queue_free()

	for action in [
		"view_mode_1",
		"view_mode_2",
		"view_mode_3",
		"view_mode_4",
	]:
		var new_label = Label.new()
		new_label.text = str(InputMap.action_get_events(action)[0].as_text().to_upper()) + ": " + action
		%KeyBindingsBlock1.add_child(new_label)

	for action in [
		"shift_view_backward",
		"previous_day",
		"jump_to_today",
		"next_day",
		"shift_view_forward",
	]:
		var new_label = Label.new()
		new_label.text = str(InputMap.action_get_events(action)[0].as_text().to_upper()) + ": " + action
		%KeyBindingsBlock2.add_child(new_label)

	for action in [
		"toggle_calendar_widget",
		"search_screen",
		"show_help",
		"show_alarms",
		"show_capture",
		"toggle_fullscreen",
		"toggle_dark_mode",
	]:
		var new_label = Label.new()
		new_label.text = str(InputMap.action_get_events(action)[0].as_text().to_upper()) + ": " + action
		%KeyBindingsBlock3.add_child(new_label)
