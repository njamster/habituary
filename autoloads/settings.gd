extends Node

const SETTINGS_PATH := "user://settings.cfg"

var date_format_save := "YYYY-MM-DD"

var store_path:
	get:
		if OS.is_debug_build():
			return "user://"
		else:
			var path := "/" + str(ProjectSettings.get("application/config/name")).to_snake_case()

			if OS.has_feature("windows"):
				path = OS.get_environment("USERPROFILE") + path
			else:
				path = OS.get_environment("HOME") + path

			return path

var view_mode := 3:
	set(value):
		view_mode = value
		EventBus.view_mode_changed.emit(view_mode)

var current_day := DayTimer.today:
	set(value):
		if current_day.day_difference_to(value) != 0:
			current_day = value
			EventBus.current_day_changed.emit(current_day)


func _enter_tree() -> void:
	if OS.is_debug_build():
		return

	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if not error:
		view_mode = config.get_value("AppState", "view_mode", view_mode)


func _notification(what: int) -> void:
	if OS.is_debug_build():
		return

	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var config = ConfigFile.new()
		config.load(SETTINGS_PATH) # keep existing settings (if there are any)
		config.set_value("AppState", "view_mode", view_mode)
		config.save(SETTINGS_PATH)


