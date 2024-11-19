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

	# Adjust current_time relative to the (potentially offset) day start, e.g.:
	# current_time == 1:13 with day start == 2:17 => current_time (adjusted) == 22:56
	current_time.hour = wrapi(current_time.hour - Settings.day_start_hour_offset, 0, 24)
	if current_time.minute - Settings.day_start_minute_offset < 0:
		current_time.hour -= 1
	current_time.minute = wrapi(current_time.minute - Settings.day_start_minute_offset, 0, 60)

	# Now simply calculate the seconds till the end of the day, using that current_time value:
	var seconds_till_tomorrow := 0
	# First, calculate remaining seconds until the next full minute
	seconds_till_tomorrow += 60 - current_time.second
	# Then, calculate remaining seconds until the next full hour
	seconds_till_tomorrow += (60 - current_time.minute - 1) * 60
	# Finally, calculate remaining seconds until the next full day
	seconds_till_tomorrow += (24 - current_time.hour - 1) * SECONDS_PER_HOUR

	return seconds_till_tomorrow


func _on_new_day() -> void:
	today = today.add_days(1)
	self.start(SECONDS_PER_DAY)


func _on_day_start_changed() -> void:
	var old_time_left := self.time_left
	var new_time_left := _get_seconds_till_tomorrow()

	if old_time_left < SECONDS_PER_DAY and new_time_left > SECONDS_PER_DAY:
		# the new offset shifted the day start above 24 hours into the future => decrease today
		today = today.add_days(-1)
	elif old_time_left > SECONDS_PER_DAY and new_time_left < SECONDS_PER_DAY:
		# the new offset shifted the  day start below 24 hours into the future => increase today
		today = today.add_days(1)

	self.start(new_time_left)
