extends PanelContainer

var date : Date:
	set(value):
		date = value
		if date:
			_update_day_counter()

var text := "":
	set(value):
		text = value
		%SearchQuery.text = text

var warning_threshold := Utils.MIN_INT

# used for sorting
var day_diff := Utils.MIN_INT
var line_id : int


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


func _setup_initial_state() -> void:
	date = _find_last_mention()


func _find_last_mention() -> Date:
	# Reverse key order: future dates first, past dates last.
	var cache_keys := Cache.data.keys()
	cache_keys.sort_custom(func(a, b): return a > b)

	# Search all cached contents for items matching the search query.
	for key in cache_keys:
		# FIXME: Temporary workaround, since the capture has no associated date,
		# thus it's not possible to jump to a captured to-do item yet
		if key == "capture" or key == "saved_searches":
			continue  # with next key

		line_id = 0
		for line in Cache.data[key].content:
			var stripped_line := Utils.strip_tags(line)
			if stripped_line.contains(text):
				return Date.from_string(key)
			line_id += 1

	%DayCounter.hide()
	return null


func _connect_signals() -> void:
	#region Global Signals
	EventBus.today_changed.connect(func():
		self.date = self.date
	)

	EventBus.saved_search_update_requested.connect(func(query):
		if query == text:
			date = _find_last_mention()
	)
	#endregion

	#region Local Signals
	%RepeatSearch.pressed.connect(_on_repeat_search_pressed)
	#endregion


func _update_day_counter() -> void:
	day_diff = date.day_difference_to(DayTimer.today)
#
	var years := int(abs(day_diff) / 365)
	var weeks := int(abs(day_diff) % 365 / 7)
	var days := int(abs(day_diff) % 365 % 7)

	var remaining_time = ""
	if years:
		if years > 1:
			remaining_time += "%d years" % [years]
		else:
			remaining_time += "%d year" % [years]
	if weeks:
		if remaining_time:
			if days:
				remaining_time += ", "
			else:
				remaining_time += " and "
		if weeks > 1:
			remaining_time += "%d weeks" % [weeks]
		else:
			remaining_time += "%d week" % [weeks]
	if days:
		if remaining_time:
			remaining_time += " and "
		if days > 1:
			remaining_time += "%d days" % [days]
		else:
			remaining_time += "%d day" % [days]

	if day_diff < 0:
		if day_diff == -1:
			%DayCounter.text = "Yesterday"
		else:
			%DayCounter.text = remaining_time + " ago"
	elif day_diff > 0:
		if day_diff == 1:
			%DayCounter.text = "Tomorrow"
		else:
			%DayCounter.text = "in " + remaining_time
	else:
		%DayCounter.text = "TODAY"

	if day_diff <= warning_threshold:
		%DayCounter.add_theme_color_override("font_color", Color.RED)
	else:
		%DayCounter.remove_theme_color_override("font_color")

	%Tooltip.text = date.format("MMM DD, YYYY")


func _on_repeat_search_pressed() -> void:
	Settings.search_query = text
	EventBus.global_search_requested.emit()
