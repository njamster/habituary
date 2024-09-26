extends PanelContainer

var date : Date:
	set(value):
		date = value
		%Tooltip.text = date.format("MMM DD, YYYY")

		# reset formatting
		%DayCounter.remove_theme_color_override("font_color")
		modulate.a = 1.0

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
			modulate.a = 0.4
			%DayCounter.remove_theme_color_override("font_color")
			%DayCounter.text = remaining_time + " ago"
		elif day_diff > 0:
			modulate.a = 1.0
			%DayCounter.remove_theme_color_override("font_color")
			%DayCounter.text = remaining_time + " remaining"
		else:
			modulate.a = 1.0
			%DayCounter.add_theme_color_override("font_color", "ebcb8b")
			%DayCounter.text = "TODAY"

var text := "":
	set(value):
		text = value
		%Heading.text = text


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		Settings.current_day = date
