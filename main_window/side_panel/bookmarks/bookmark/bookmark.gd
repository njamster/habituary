extends PanelContainer

var date : Date:
	set(value):
		date = value
		%Tooltip.text = date.format("MMM DD, YYYY")

		# reset formatting
		%DayCounter.remove_theme_color_override("font_color")
		modulate.a = 1.0

		_apply_date_relative_formating()

var _is_past_date := false

var text := "":
	set(value):
		text = value
		%Heading.text = text

var is_bold := false:
	set(value):
		is_bold = value
		_apply_formatting()

var is_italic := false:
	set(value):
		is_italic = value
		_apply_formatting()


func _ready() -> void:
	EventBus.today_changed.connect(_apply_date_relative_formating)

	EventBus.show_bookmarks_from_the_past_changed.connect(_on_show_bookmarks_from_the_past_changed)
	_on_show_bookmarks_from_the_past_changed()


func _apply_date_relative_formating() -> void:
	var day_diff := date.day_difference_to(DayTimer.today)

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
		_is_past_date = true
		modulate.a = 0.4
		%DayCounter.remove_theme_color_override("font_color")
		%DayCounter.text = remaining_time + " ago"
	elif day_diff > 0:
		_is_past_date = false
		modulate.a = 1.0
		%DayCounter.remove_theme_color_override("font_color")
		%DayCounter.text = remaining_time + " remaining"
	else:
		_is_past_date = false
		modulate.a = 1.0
		%DayCounter.add_theme_color_override("font_color", "ebcb8b")
		%DayCounter.text = "TODAY"


func _on_show_bookmarks_from_the_past_changed() -> void:
	self.visible = (not _is_past_date or Settings.show_bookmarks_from_the_past)


func _apply_formatting() -> void:
	var font : Font

	if is_bold:
		if is_italic:
			font = preload("res://theme/fonts/OpenSans-ExtraBoldItalic.ttf")
		else:
			font = preload("res://theme/fonts/OpenSans-ExtraBold.ttf")
	else:
		if is_italic:
			font = preload("res://theme/fonts/OpenSans-MediumItalic.ttf")
		else:
			font = preload("res://theme/fonts/OpenSans-Medium.ttf")

	%Heading.add_theme_font_override("font", font)


func _on_jump_to_pressed() -> void:
	Settings.current_day = date
	EventBus.bookmark_jump_requested.emit(text)
