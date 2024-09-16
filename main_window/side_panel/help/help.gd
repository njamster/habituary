extends VBoxContainer


var descriptions := {
	"view_mode_1": "Change View To Show 1 Day",
	"view_mode_2": "Change View To Show 3 Days",
	"view_mode_3": "Change View To Show 5 Days",
	"view_mode_4": "Change View To Show 7 Days",

	"shift_view_backward": "Shift 1 View Backward",
	"previous_day": "Shift 1 Day Backward",
	"jump_to_today": "Jump To Today",
	"next_day": "Shift 1 Day Forward",
	"shift_view_forward": "Shift 1 View Forward",

	"toggle_calendar_widget": "Open/Close Calendar Widget",
	"search_screen": "Search To-Dos On Screen",
	"show_help": "Open/Close Help Panel",
	"show_bookmarks": "Open/Close Bookmarks Panel",
	"show_capture": "Open/Close Capture Panel",
	"toggle_fullscreen": "Toggle Fullscreen On/Off",
	"toggle_dark_mode": "Toggle Dark Mode On/Off",
}


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
		var hint = preload("input_hint/input_hint.tscn").instantiate()
		hint.description = descriptions[action]
		hint.key_binding = InputMap.action_get_events(action)[0]
		%KeyBindingsBlock1.add_child(hint)

	for action in [
		"shift_view_backward",
		"previous_day",
		"jump_to_today",
		"next_day",
		"shift_view_forward",
	]:
		var hint = preload("input_hint/input_hint.tscn").instantiate()
		hint.description = descriptions[action]
		hint.key_binding = InputMap.action_get_events(action)[0]
		%KeyBindingsBlock2.add_child(hint)

	for action in [
		"search_screen",
	]:
		var hint = preload("input_hint/input_hint.tscn").instantiate()
		hint.description = descriptions[action]
		hint.key_binding = InputMap.action_get_events(action)[0]
		%KeyBindingsBlock3.add_child(hint)

	for action in [
		"toggle_calendar_widget",
		"show_help",
		"show_bookmarks",
		"show_capture",
		"toggle_fullscreen",
		"toggle_dark_mode",
	]:
		var hint = preload("input_hint/input_hint.tscn").instantiate()
		hint.description = descriptions[action]
		hint.key_binding = InputMap.action_get_events(action)[0]
		%KeyBindingsBlock4.add_child(hint)
