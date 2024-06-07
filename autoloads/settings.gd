extends Node

var date_format_show := "dddd, MMMM Do YYYY"
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

var save_delay := 6.0 # seconds
