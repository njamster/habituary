extends Node


enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}


const MICROSECONDS_PER_HOUR := 3_600_000_000
const MICROSECONDS_PER_MINUTE := 60_000_000
const MICROSECONDS_PER_SECOND := 1_000_000

const _colors := {
	Level.DEBUG: "",
	Level.INFO: "",
	Level.WARNING: "orange",
	Level.ERROR: "red",
}


var mute_everything_below := Level.DEBUG

var allowed_sources := [
	# A source is described by a "<filepath>:<function_name>"-string, e.g.:
	# "res://autoloads/settings.gd:_ready"
]


func _log(level, message) -> void:
	if level < mute_everything_below:
		return  # early

	if allowed_sources:
		var backtrace := Engine.capture_script_backtraces()[0]
		var source := "%s:%s" % [
			backtrace.get_frame_file(2),
			backtrace.get_frame_function(2)
		]
		if source not in allowed_sources:
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
	var microseconds_since_boot := Time.get_ticks_usec()

	var hours = microseconds_since_boot / MICROSECONDS_PER_HOUR
	var remaining_microseconds = microseconds_since_boot % MICROSECONDS_PER_HOUR

	var minutes = remaining_microseconds / MICROSECONDS_PER_MINUTE
	remaining_microseconds = remaining_microseconds % MICROSECONDS_PER_MINUTE

	var seconds = remaining_microseconds / MICROSECONDS_PER_SECOND
	remaining_microseconds = remaining_microseconds % MICROSECONDS_PER_SECOND

	return "%02d:%02d:%02d.%-6d" % [
		hours,
		minutes,
		seconds,
		remaining_microseconds
	]


func debug(message) -> void:
	_log(Level.DEBUG, message)


func info(message) -> void:
	_log(Level.INFO, message)


func warn(message) -> void:
	_log(Level.WARNING, message)


func error(message) -> void:
	_log(Level.ERROR, message)
