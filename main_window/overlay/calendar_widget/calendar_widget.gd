extends PanelContainer


signal day_button_pressed(date)


@export var day_button_tooltip := "Click to jump to this date"

@export var include_past_dates := true
@export var include_today := true


var anchor_date: Date


var _mouse_over_month_button := false
var _mouse_over_month_popup_menu := false


@onready var month_popup_menu: PopupMenu = %MonthButton.get_popup()


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	%MonthButton.show()
	%YearLabel.show()
	%YearSpinBox.hide()

	_on_visibility_changed()


func _connect_signals() -> void:
	#region Local Signals
	item_rect_changed.connect(_on_item_rect_changed)
	visibility_changed.connect(_on_visibility_changed)

	%MonthButton.mouse_entered.connect(_on_month_button_mouse_entered)
	%MonthButton/HoverTimer.timeout.connect(_on_month_button_hover_timer_timeout)
	%MonthButton.toggled.connect(_on_month_button_toggled)
	%MonthButton.mouse_exited.connect(_on_month_button_mouse_exited)

	month_popup_menu.id_pressed.connect(_on_month_selected)
	month_popup_menu.mouse_entered.connect(_on_month_popup_menu_mouse_entered)
	month_popup_menu.mouse_exited.connect(_on_month_popup_menu_mouse_exited)

	%YearLabel.mouse_entered.connect(_on_year_label_mouse_entered)
	%YearLabel/HoverTimer.timeout.connect(_on_year_label_hover_timer_timeout)
	%YearLabel.mouse_exited.connect(_on_year_label_mouse_exited)

	%YearSpinBox.value_changed.connect(_on_year_spin_box_value_changed)
	%YearSpinBox.mouse_exited.connect(_on_year_spin_box_mouse_exited)

	%PreviousMonth.pressed.connect(_on_previous_month_pressed)

	%Today.pressed.connect(reset_view_to_today)

	%NextMonth.pressed.connect(_on_next_month_pressed)
	#endregion


func _on_visibility_changed() -> void:
	if visible:
		anchor_date = Date.new(Settings.current_day.as_dict())
		if not Settings.current_day_changed.is_connected(_on_current_day_changed):
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
	for child in $VBox/GridContainer.get_children():
		if child is not DayButton:
			continue

		var button := child as DayButton

		if button.associated_day.equals(Settings.current_day):
			button.theme_type_variation = "CalendarWidget_DayButton_Selected"
			button.modulate.a = 1.0
		elif button.associated_day.equals(DayTimer.today):
			button.theme_type_variation = "CalendarWidget_DayButton_Today"
			button.modulate.a = 1.0
		elif button.theme_type_variation == "CalendarWidget_DayButton_Selected":
			if button.associated_day.is_weekend_day():
				button.theme_type_variation = "CalendarWidget_DayButton_WeekendDay"
			else:
				button.theme_type_variation = "CalendarWidget_DayButton"

			if not FileAccess.file_exists(Settings.store_path.path_join(
				button.associated_day.format(Settings.date_format_save)
			) + ".txt"):
				button.modulate.a = 0.55


func update_month() -> void:
	if not include_past_dates:
		if anchor_date.day_difference_to(DayTimer.today) <= 0:
			anchor_date = DayTimer.today
			%PreviousMonth.disabled = true
			%PreviousMonth.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		else:
			%PreviousMonth.disabled = false
			%PreviousMonth.mouse_default_cursor_shape = CURSOR_POINTING_HAND

	# update the title
	%MonthButton.text = Date._MONTH_NAMES[anchor_date.month - 1].to_upper()
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
		start_offset = wrapi(date.weekday - 1, 0, 7)
	else:
		start_offset = date.weekday

	date = date.add_days(-1 * start_offset)

	# add some padding/days from the previous month, if the current month does
	# not start on the first day of the week
	for i in range(start_offset):
		if not Settings.show_outside_month_dates or not include_past_dates:
			$VBox/GridContainer.add_child(Control.new())
		else:
			var button := DayButton.new(date)
			button.tooltip.text = day_button_tooltip
			if date.is_weekend_day():
				button.theme_type_variation = "CalendarWidget_DayButton_WeekendDay"

			if not FileAccess.file_exists(Settings.store_path.path_join(
				date.format(Settings.date_format_save)
			) + ".txt"):
				button.modulate.a = 0.2
			else:
				button.modulate.a = 0.3

			button.pressed.connect(
				day_button_pressed.emit.bind(button.associated_day)
			)
			$VBox/GridContainer.add_child(button)
		date = date.add_days(1)

	# add the days from the current month
	for i in range(Date._days_in_month(anchor_date.month, anchor_date.year)):
		if (not include_past_dates and date.day_difference_to(DayTimer.today) < 0) or \
			(not include_today and date.equals(DayTimer.today)):
				var placeholder = Control.new()
				placeholder.custom_minimum_size = Vector2(28, 28)
				$VBox/GridContainer.add_child(placeholder)
		else:
			var button := DayButton.new(date)
			button.tooltip.text = day_button_tooltip
			if date.equals(Settings.current_day):
				button.theme_type_variation = "CalendarWidget_DayButton_Selected"
			elif date.equals(DayTimer.today):
				button.theme_type_variation = "CalendarWidget_DayButton_Today"
			else:
				if date.is_weekend_day():
					button.theme_type_variation = "CalendarWidget_DayButton_WeekendDay"

				if not FileAccess.file_exists(Settings.store_path.path_join(
					date.format(Settings.date_format_save)
				) + ".txt"):
					button.modulate.a = 0.55
			button.pressed.connect(
					day_button_pressed.emit.bind(button.associated_day)
				)
			$VBox/GridContainer.add_child(button)
		date = date.add_days(1)

	# add some padding/days from the next month, if the current month does not
	# end on the last day of the week (until the row is filled)
	while $VBox/GridContainer.get_child_count() % 7 != 0:
		if not Settings.show_outside_month_dates:
			$VBox/GridContainer.add_child(Control.new())
		else:
			var button := DayButton.new(date)
			button.tooltip.text = day_button_tooltip
			if date.is_weekend_day():
				button.theme_type_variation = "CalendarWidget_DayButton_WeekendDay"

			if not FileAccess.file_exists(Settings.store_path.path_join(
				date.format(Settings.date_format_save)
			) + ".txt"):
				button.modulate.a = 0.2
			else:
				button.modulate.a = 0.3

			button.pressed.connect(
				day_button_pressed.emit.bind(button.associated_day)
			)
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


func reset_view_to_today() -> void:
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
	%YearLabel/HoverTimer.start()


func _on_year_label_hover_timer_timeout() -> void:
	%YearLabel.hide()
	%YearSpinBox.show()
	%YearSpinBox.value = int(%YearLabel.text)
	%YearSpinBox.get_line_edit().grab_focus()


func _on_year_label_mouse_exited() -> void:
	%YearLabel/HoverTimer.stop()


func _on_year_spin_box_mouse_exited() -> void:
	%YearSpinBox.hide()
	%YearLabel.show()


func _on_year_spin_box_value_changed(value: float) -> void:
	var change := int(value) - anchor_date.year
	anchor_date = anchor_date.add_months(change * 12)
	update_month()


func _on_month_button_mouse_entered():
	_mouse_over_month_button = true
	%MonthButton/HoverTimer.start()


func _on_month_button_hover_timer_timeout() -> void:
	%MonthButton.show_popup()
	month_popup_menu.set_focused_item(-1)


func _on_month_button_toggled(_toggled_on: bool) -> void:
	%MonthButton/HoverTimer.stop()


func _on_month_button_mouse_exited() -> void:
	_mouse_over_month_button = false
	%MonthButton/HoverTimer.stop()
	await get_tree().process_frame
	if not (_mouse_over_month_button or _mouse_over_month_popup_menu):
		month_popup_menu.hide()


func _on_month_popup_menu_mouse_entered() -> void:
	_mouse_over_month_popup_menu = true


func _on_month_popup_menu_mouse_exited() -> void:
	_mouse_over_month_popup_menu = false
	await get_tree().process_frame
	if not (_mouse_over_month_button or _mouse_over_month_popup_menu):
		month_popup_menu.hide()
