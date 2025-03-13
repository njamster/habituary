extends PanelContainer


signal closed


var anchor_date : Date


func _ready() -> void:
	_connect_signals()

	%Month.show()
	%YearLabel.show()

	var popup_menu : PopupMenu = %Month.get_popup()
	popup_menu.id_pressed.connect(_on_month_selected)
	popup_menu.mouse_exited.connect(popup_menu.hide)


func _connect_signals() -> void:
	#region Local Signals
	item_rect_changed.connect(_on_item_rect_changed)
	visibility_changed.connect(_on_visibility_changed)

	%Month.mouse_entered.connect(_on_month_mouse_entered)
	%Month.mouse_exited.connect(_on_month_mouse_exited)

	%YearLabel.mouse_entered.connect(_on_year_label_mouse_entered)

	%YearSpinBox.value_changed.connect(_on_year_spin_box_value_changed)
	%YearSpinBox.mouse_exited.connect(_on_year_spin_box_mouse_exited)

	%PreviousMonth.pressed.connect(_on_previous_month_pressed)

	%Today.pressed.connect(_on_today_pressed)

	%NextMonth.pressed.connect(_on_next_month_pressed)
	#endregion


func _on_visibility_changed() -> void:
	if visible:
		anchor_date = Date.new(Settings.current_day.as_dict())
		Settings.current_day_changed.connect(_on_current_day_changed)
		update_month()
	else:
		if Settings.current_day_changed.is_connected(_on_current_day_changed):
			Settings.current_day_changed.disconnect(_on_current_day_changed)


func _on_current_day_changed() -> void:
	var current_day := Settings.current_day
	if current_day.year != anchor_date.year or current_day.month != anchor_date.month:
		# jump to the correct year and month in the calendar widget
		anchor_date.year = current_day.year
		anchor_date.month = current_day.month
		update_month()
	else:
		update_day()


func update_day() -> void:
	var first_button_id = 0
	for child in $VBox/GridContainer.get_children():
		if child is Button:
			break
		else:
			first_button_id += 1

	for i in range(Date._days_in_month(anchor_date.month, anchor_date.year)):
		var child_id = first_button_id + i
		var button := $VBox/GridContainer.get_child(child_id)
		if i+1 == Settings.current_day.day:
			button.theme_type_variation = "CalendarWidget_DayButton_Selected"
			button.modulate.a = 1.0
		elif i+1 == DayTimer.today.day and anchor_date.month == DayTimer.today.month and \
			anchor_date.year == DayTimer.today.year:
				button.theme_type_variation = "CalendarWidget_DayButton_Today"
				button.modulate.a = 1.0
		elif button.theme_type_variation == "CalendarWidget_DayButton_Selected":
			if child_id % 7 == 5 or child_id % 7 == 6:
				button.theme_type_variation = "CalendarWidget_DayButton_WeekendDay"
			else:
				button.theme_type_variation = "CalendarWidget_DayButton"

			var date = anchor_date.duplicate()
			date.day = i+1
			if not FileAccess.file_exists(Settings.store_path.path_join(
				date.format(Settings.date_format_save)
			) + ".txt"):
				button.modulate.a = 0.65


func update_month() -> void:
	# update the title
	%Month.text = Date._MONTH_NAMES[anchor_date.month - 1].to_upper()
	%YearLabel.text = str(anchor_date.year)

	# remove old children
	for child in $VBox/GridContainer.get_children():
		$VBox/GridContainer.remove_child(child)
		child.queue_free()

	# add new children
	var day_names = Array()
	day_names.assign(Date._DAY_NAMES)
	if not Settings.start_week_on_monday:
		day_names.push_front(day_names.pop_back())

	for day_name in day_names:
		var label = Label.new()
		label.modulate.a = 0.65
		label.text = day_name.left(2)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		$VBox/GridContainer.add_child(label)
		if day_name == "Saturday" or day_name == "Sunday":
			label.theme_type_variation = "Label_WeekendDay"

	var date = Date.new(anchor_date.as_dict())
	date.day = 1

	var start_offset := 0
	if Settings.start_week_on_monday:
		start_offset = wrapi(date.weekday - 1, 0, 6)
	else:
		start_offset = date.weekday

	date = date.add_days(-1 * start_offset)

	# add some padding/days from the previous month, if the current month does
	# not start on the first day of the week
	for i in range(start_offset):
		if not Settings.show_outside_month_dates:
			$VBox/GridContainer.add_child(Control.new())
		else:
			var button := DayButton.new(date)
			if date.weekday == 0:
				button.theme_type_variation = "CalendarWidget_DayButton_WeekendDay"

			if not FileAccess.file_exists(Settings.store_path.path_join(
				date.format(Settings.date_format_save)
			) + ".txt"):
				button.modulate.a = 0.2
			else:
				button.modulate.a = 0.3

			button.pressed.connect(closed.emit)
			$VBox/GridContainer.add_child(button)
		date = date.add_days(1)

	# add the days from the current month
	for i in range(Date._days_in_month(anchor_date.month, anchor_date.year)):
		var button := DayButton.new(date)
		if date.as_dict() == Settings.current_day.as_dict():
			button.theme_type_variation = "CalendarWidget_DayButton_Selected"
		elif date.as_dict() == DayTimer.today.as_dict():
			button.theme_type_variation = "CalendarWidget_DayButton_Today"
		else:
			if date.weekday == 0 or date.weekday == 6:
				button.theme_type_variation = "CalendarWidget_DayButton_WeekendDay"

			if not FileAccess.file_exists(Settings.store_path.path_join(
				date.format(Settings.date_format_save)
			) + ".txt"):
				button.modulate.a = 0.55
		button.pressed.connect(closed.emit)
		$VBox/GridContainer.add_child(button)
		date = date.add_days(1)

	# add some padding/days from the next month, if the current month does not
	# end on the last day of the week (until the row is filled)
	while $VBox/GridContainer.get_child_count() % 7 != 0:
		if not Settings.show_outside_month_dates:
			$VBox/GridContainer.add_child(Control.new())
		else:
			var button := DayButton.new(date)
			if date.weekday == 0 or date.weekday == 6:
				button.theme_type_variation = "CalendarWidget_DayButton_WeekendDay"

			if not FileAccess.file_exists(Settings.store_path.path_join(
				date.format(Settings.date_format_save)
			) + ".txt"):
				button.modulate.a = 0.2
			else:
				button.modulate.a = 0.3

			button.pressed.connect(closed.emit)
			$VBox/GridContainer.add_child(button)
			date = date.add_days(1)

	# disable today button if we're already in the correct month (button wouldn't do anything)
	if anchor_date.year == DayTimer.today.year and anchor_date.month == DayTimer.today.month:
		$VBox/HBox/Today.disabled = true
		$VBox/HBox/Today.mouse_default_cursor_shape = CURSOR_FORBIDDEN
	else:
		$VBox/HBox/Today.disabled = false
		$VBox/HBox/Today.mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _on_previous_month_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		anchor_date = anchor_date.add_months(-12)
	else:
		anchor_date = anchor_date.add_months(-1)
	update_month()


func _on_today_pressed() -> void:
	anchor_date = Date.new(DayTimer.today.as_dict())
	update_month()


func _on_next_month_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		anchor_date = anchor_date.add_months(12)
	else:
		anchor_date = anchor_date.add_months(1)
	update_month()


func _on_item_rect_changed() -> void:
	set_meta("x_padding", 2 * abs(offset_right))
	set_meta("y_padding", 18 + offset_top)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SHIFT:
		if event.pressed:
			$VBox/HBox/PreviousMonth/Tooltip.text = "Previous Year"
			$VBox/HBox/NextMonth/Tooltip.text = "Next Year"
		else:

			$VBox/HBox/PreviousMonth/Tooltip.text = "Previous Month"
			$VBox/HBox/NextMonth/Tooltip.text = "Next Month"


func _on_month_selected(selected_id : int) -> void:
	var change := selected_id - anchor_date.month
	anchor_date = anchor_date.add_months(change)
	update_month()


func _on_year_label_mouse_entered() -> void:
	%YearLabel.hide()
	%YearSpinBox.show()
	%YearSpinBox.value = int(%YearLabel.text)
	%YearSpinBox.get_line_edit().grab_focus()


func _on_year_spin_box_mouse_exited() -> void:
	%YearSpinBox.hide()
	%YearLabel.show()


func _on_year_spin_box_value_changed(value: float) -> void:
	var change := int(value) - anchor_date.year
	anchor_date = anchor_date.add_months(change * 12)
	update_month()


func _on_month_mouse_entered():
	%Month.show_popup()
	%Month.get_popup().set_focused_item(-1)


func _on_month_mouse_exited() -> void:
	await get_tree().process_frame
	if %Month.get_popup().get_focused_item() == -1:
		%Month.get_popup().hide()
