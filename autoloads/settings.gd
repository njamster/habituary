extends Node

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

var view_mode := 7:
	set(value):
		view_mode = value
		EventBus.view_mode_changed.emit(view_mode)

var current_day := DayTimer.today:
	set(value):
		current_day = value
		EventBus.current_day_changed.emit(current_day)

