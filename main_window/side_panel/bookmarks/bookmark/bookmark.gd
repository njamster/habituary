extends PanelContainer

var date : Date:
	set(value):
		var old_date
		if date:
			if date.day_difference_to(value) != 0:
				old_date = date
			else:
				return # early
		date = value
		%Tooltip.text = date.format("MMM DD, YYYY")

		# reset formatting
		%DayCounter.remove_theme_color_override("font_color")
		modulate.a = 1.0
		%JumpTo.modulate.a = 1.0

		_apply_date_relative_formating()

		if not is_done:
			if old_date and old_date.day_difference_to(DayTimer.today) == 0:
				Settings.bookmarks_due_today -= 1
			else:
				if date.day_difference_to(DayTimer.today) == 0:
					Settings.bookmarks_due_today += 1

var line_number := -1

var day_diff := 0

var text := "":
	set(value):
		text = value
		%Heading.text = text

var is_done := false:
	set(value):
		var old_value = is_done
		is_done = value
		if day_diff == 0:
			if is_done:
				modulate.a = 0.4
				%JumpTo.modulate.a = 2.5
				%DayCounter.remove_theme_color_override("font_color")
				if not old_value:
					Settings.bookmarks_due_today -= 1
			else:
				modulate.a = 1.0
				%JumpTo.modulate.a = 1.0
				%DayCounter.add_theme_color_override("font_color", "a3be8c")
				if old_value:
					Settings.bookmarks_due_today += 1
		_on_show_bookmarks_from_the_past_changed()

var updated_this_frame := false


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	EventBus.today_changed.connect(func():
		self.date = self.date
		self.is_done = self.is_done
		_apply_date_relative_formating()
	)

	Settings.show_bookmarks_from_the_past_changed.connect(_on_show_bookmarks_from_the_past_changed)
	_on_show_bookmarks_from_the_past_changed()
	#endregion

	#region Local Signals
	%JumpTo.pressed.connect(_on_jump_to_pressed)
	#endregion


func _apply_date_relative_formating() -> void:
	day_diff = date.day_difference_to(DayTimer.today)

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
		modulate.a = 0.4
		%JumpTo.modulate.a = 2.5
		%DayCounter.remove_theme_color_override("font_color")
		if day_diff == -1:
			%DayCounter.text = "Yesterday"
		else:
			%DayCounter.text = remaining_time + " ago"
		theme_type_variation = ""
	elif day_diff > 0:
		modulate.a = 1.0
		%JumpTo.modulate.a = 1.0
		%DayCounter.remove_theme_color_override("font_color")
		if day_diff == 1:
			%DayCounter.text = "Tomorrow"
		else:
			%DayCounter.text = "in " + remaining_time
		theme_type_variation = ""
	else:
		modulate.a = 1.0
		%JumpTo.modulate.a = 1.0
		%DayCounter.add_theme_color_override("font_color", "a3be8c")
		%DayCounter.text = "TODAY"
		theme_type_variation = "Bookmark_Today"


func _on_show_bookmarks_from_the_past_changed() -> void:
	self.visible = Settings.show_bookmarks_from_the_past or \
		day_diff > 0 or (day_diff == 0 and not is_done)


func _on_jump_to_pressed() -> void:
	Settings.main_panel = Settings.MainPanelState.LIST_VIEW
	Settings.current_day = date
	EventBus.bookmark_jump_requested.emit(date, line_number)


func remove() -> void:
	if date.day_difference_to(DayTimer.today) == 0 and not is_done:
		Settings.bookmarks_due_today -= 1
	queue_free()
