extends PanelContainer

var date : Date:
	set(value):
		date = value
		%Tooltip.text = date.format("MMM DD, YYYY")

		# reset formatting
		%DayCounter.remove_theme_color_override("font_color")
		modulate.a = 1.0

		# apply formatting
		var day_diff := date.day_difference_to(DayTimer.today)
		if day_diff < 0:
			modulate.a = 0.4
			if day_diff == -1:
				%DayCounter.text = "%d day ago" % abs(day_diff)
			else:
				%DayCounter.text = "%d days ago" % abs(day_diff)
		elif day_diff > 0:
			if day_diff == 1:
				%DayCounter.text = "%d day left" % day_diff
			else:
				%DayCounter.text = "%d days left" % day_diff
		else:
			%DayCounter.add_theme_color_override("font_color", "ebcb8b")
			%DayCounter.text = "Today"

var text := "":
	set(value):
		text = value
		%Heading.text = text


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		Settings.current_day = date
