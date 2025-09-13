extends Node


enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}


const _colors := {
	Level.DEBUG: "",
	Level.INFO: "",
	Level.WARNING: "orange",
	Level.ERROR: "red",
}


var mute_everything_below := Level.DEBUG


func _log(level, message) -> void:
	if level < mute_everything_below:
		return  # early

	print_rich(
		"[color={color}]{time} [b][{level}][/b]: {message}[/color]".format({
			"color": _colors[level],
			"time": Time.get_datetime_string_from_system(false, true),
			"level": Level.keys()[level],
			"message": message
		})
	)


func debug(message) -> void:
	_log(Level.DEBUG, message)


func info(message) -> void:
	_log(Level.INFO, message)


func warn(message) -> void:
	_log(Level.WARNING, message)


func error(message) -> void:
	_log(Level.ERROR, message)
