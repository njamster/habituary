@tool
extends Timer

var today := Date.new():
	set(value):
		if Settings.current_day.as_dict() == today.as_dict():
			Settings.current_day = value
		today = value
		EventBus.today_changed.emit()


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	self.start(_get_seconds_till_tomorrow())

	timeout.connect(_on_new_day)

	EventBus.day_start_hour_offset_changed.connect(_on_day_start_hour_offset_changed)


func _get_seconds_till_tomorrow() -> int:
	var seconds_till_tomorrow := 0
	var current_time := Time.get_time_dict_from_system()
	seconds_till_tomorrow += 60 - current_time.second
	seconds_till_tomorrow += (60 - current_time.minute - 1) * 60
	seconds_till_tomorrow += (24 + Settings.day_start_hour_offset - current_time.hour - 1) * 3600
	return seconds_till_tomorrow


func _on_new_day() -> void:
	today = today.add_days(1)

	self.start(_get_seconds_till_tomorrow())


func _on_day_start_hour_offset_changed(shift : int) -> void:
	var new_time_till_day_start := self.wait_time + shift * 3600

	if new_time_till_day_start >= 86400:
		# day start is 24 hours or more away => decrease today by one
		today = today.add_days(-1)
	elif new_time_till_day_start < 0:
		# day start is already in the past => increase today by one
		today = today.add_days(1)

	self.start(_get_seconds_till_tomorrow())
