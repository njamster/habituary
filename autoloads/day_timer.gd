@tool
extends Timer

var today := Date.new()


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	wait_time = _get_seconds_till_tomorrow()
	start()

	timeout.connect(_on_new_day)


func _get_seconds_till_tomorrow() -> int:
	var seconds_till_tomorrow := 0
	var current_time := Time.get_time_dict_from_system()
	seconds_till_tomorrow += 60 - current_time.second
	seconds_till_tomorrow += (60 - current_time.minute - 1) * 60
	seconds_till_tomorrow += (24 - current_time.hour - 1) * 3600
	return seconds_till_tomorrow


func _on_new_day() -> void:
	today = today.add_days(1)
	EventBus.new_day_started.emit()
	wait_time = _get_seconds_till_tomorrow()
