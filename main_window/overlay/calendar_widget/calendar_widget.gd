extends PanelContainer

var anchor_date : Date


func _on_visibility_changed() -> void:
	if visible:
		anchor_date = Date.new(Settings.current_day.as_dict())
		update_month()


func update_month() -> void:
	# update the title
	%MonthName.text = "%s %d" % [
		Date._MONTH_NAMES[anchor_date.month - 1].to_upper(),
		 anchor_date.year
	]

	# remove old children
	for child in $VBox/GridContainer.get_children():
		child.queue_free()

	# add new children
	for day_name in Date._DAY_NAMES:
		var label = Label.new()
		label.modulate.a = 0.6
		label.text = day_name.left(2)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$VBox/GridContainer.add_child(label)

	var date = Date.new(anchor_date.as_dict())
	date.day = 1

	if date.weekday == 0:
		for i in range(6):
			$VBox/GridContainer.add_child(Control.new())
	elif date.weekday != 1:
		for i in range(date.weekday - 1):
			$VBox/GridContainer.add_child(Control.new())

	for i in range(Date._days_in_month(anchor_date.month, anchor_date.year)):
		var button := DayButton.new(date)
		if date.as_dict() == Settings.current_day.as_dict():
			button.theme_type_variation = "CalendarWidget_DayButton_Selected"
		elif date.as_dict() == DayTimer.today.as_dict():
			button.theme_type_variation = "CalendarWidget_DayButton_Today"
		button.pressed.connect(get_parent().close_overlay)
		$VBox/GridContainer.add_child(button)
		date = date.add_days(1)


func _on_previous_month_pressed() -> void:
	anchor_date.month -= 1
	update_month()


func _on_today_pressed() -> void:
	anchor_date = Date.new(DayTimer.today.as_dict())
	update_month()


func _on_next_month_pressed() -> void:
	anchor_date.month += 1
	update_month()