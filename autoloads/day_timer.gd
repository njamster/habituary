@tool
extends Timer

const SECONDS_PER_DAY := 86_400
const SECONDS_PER_HOUR := 3_600

var today := Date.new():
	set(value):
		if today.as_dict() != value.as_dict():
			if Settings.current_day.as_dict() == today.as_dict():
				Settings.current_day = value
			today = value
			Settings.bookmarks_due_today = 0
			EventBus.today_changed.emit()


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	timeout.connect(_on_new_day)

	var current_time := Time.get_time_dict_from_system()
	if current_time.hour * SECONDS_PER_HOUR + current_time.minute * 60 + current_time.second < \
		Settings.day_start_hour_offset * SECONDS_PER_HOUR + Settings.day_start_minute_offset * 60:
			today = today.add_days(-1)

	self.start(_get_seconds_till_tomorrow())

	EventBus.day_start_changed.connect(_on_day_start_changed)


func _get_seconds_till_tomorrow() -> int:
	var current_time := Time.get_time_dict_from_system()
	current_time.hour = wrapi(current_time.hour - Settings.day_start_hour_offset, 0, 24)
	current_time.minute = wrapi(current_time.minute - Settings.day_start_minute_offset, 0, 60)

	var seconds_till_tomorrow := 0
	seconds_till_tomorrow += 60 - current_time.second
	seconds_till_tomorrow += (59 - current_time.minute) * 60
	seconds_till_tomorrow += (23 - current_time.hour) * SECONDS_PER_HOUR
	print(seconds_till_tomorrow)
	return seconds_till_tomorrow


func _on_new_day() -> void:
	today = today.add_days(1)
	self.start(SECONDS_PER_DAY)


func _on_day_start_changed(shift_in_seconds : int) -> void:
	var new_time_till_day_start := self.time_left + shift_in_seconds
	printt(shift_in_seconds, new_time_till_day_start / 60.0 / 60.0)

	if new_time_till_day_start > SECONDS_PER_DAY:
		# new offset shifted day start more than 24 hours into the future => decrease today by one
		today = today.add_days(-1)
	elif new_time_till_day_start <= 0:
		# new offset shifted day start into the past => increase today by one
		today = today.add_days(1)

	self.start(_get_seconds_till_tomorrow())
