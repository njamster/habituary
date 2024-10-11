extends PanelContainer

var date : Date:
	set(value):
		date = value
		%Tooltip.text = date.format("MMM DD, YYYY")

		# reset formatting
		%DayCounter.remove_theme_color_override("font_color")
		modulate.a = 1.0

		_apply_date_relative_formating()

var day_diff := 0

var text := "":
	set(value):
		text = value
		%Heading.text = text

var is_done := false:
	set(value):
		is_done = value
		if day_diff == 0:
			if is_done:
				modulate.a = 0.4
				%DayCounter.remove_theme_color_override("font_color")
			else:
				modulate.a = 1.0
				%DayCounter.add_theme_color_override("font_color", "a3be8c")
		_on_show_bookmarks_from_the_past_changed()


func _ready() -> void:
	EventBus.dark_mode_changed.connect(func(dark_mode):
		if dark_mode:
			%JumpTo.remove_theme_color_override("icon_normal_color")
		else:
			%JumpTo.add_theme_color_override("icon_normal_color", Settings.NORD_00)
	)

	EventBus.today_changed.connect(_apply_date_relative_formating)

	EventBus.show_bookmarks_from_the_past_changed.connect(_on_show_bookmarks_from_the_past_changed)
	_on_show_bookmarks_from_the_past_changed()


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
		%DayCounter.remove_theme_color_override("font_color")
		%DayCounter.text = remaining_time + " ago"
		theme_type_variation = ""
	elif day_diff > 0:
		modulate.a = 1.0
		%DayCounter.remove_theme_color_override("font_color")
		%DayCounter.text = remaining_time + " remaining"
		theme_type_variation = ""
	else:
		modulate.a = 1.0
		%DayCounter.add_theme_color_override("font_color", "a3be8c")
		%DayCounter.text = "TODAY"
		theme_type_variation = "Bookmark_Today"


func _on_show_bookmarks_from_the_past_changed() -> void:
	self.visible = Settings.show_bookmarks_from_the_past or \
		day_diff > 0 or (day_diff == 0 and not is_done)


func _on_jump_to_pressed() -> void:
	Settings.current_day = date
	EventBus.bookmark_jump_requested.emit(text)
