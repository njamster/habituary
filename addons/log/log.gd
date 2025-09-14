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
			"time": get_current_timestamp(),
			"level": Level.keys()[level],
			"message": message
		})
	)


func get_current_timestamp() -> String:
	var microseconds_since_startup := Time.get_ticks_usec()
	return "%02d:%02d:%02d.%-6d" % [
		microseconds_since_startup / 3_600_000_000,  # hours
		microseconds_since_startup / 60_000_000,  # minutes
		microseconds_since_startup / 1_000_000,  # seconds
		microseconds_since_startup % 1_000_000  # microseconds
	]


func debug(message) -> void:
	_log(Level.DEBUG, message)


func info(message) -> void:
	_log(Level.INFO, message)


func warn(message) -> void:
	_log(Level.WARNING, message)


func error(message) -> void:
	_log(Level.ERROR, message)
