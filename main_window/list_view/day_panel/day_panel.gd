class_name DayPanel
extends PanelContainer


var date: Date:
	set(value):
		if date != null:
			Log.error("Cannot set 'date': Variable is immutable!")
			return
		date = value

var is_dragged := false


func _ready() -> void:
	assert(date != null, "You must provide a date in order for this node to work!")

	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	%ScrollableTodoList/%TodoList.cache_key = self.date.format(
		Settings.date_format_save
	)

	# TODO: Change Settings.date_format_save to include the "txt"-extension
	var filename := self.date.format(Settings.date_format_save) + ".txt"
	if filename in Data.files:
		%ScrollableTodoList/%TodoList.data = Data.files[filename]

	_on_view_mode_changed()
	_update_stretch_ratio()
	_on_current_day_changed()

	_update_header()

	%Header.set_drag_forwarding(
		Callable(),  # unused, no forwarding required
		%ScrollableTodoList/%TodoList/%Items._can_drop_data,
		# FIXME: This is a pretty hacky way to make sure the dragged item is
		# added to the end of the item list. It should work, though...
		func(_at_position: Vector2, data: Variant):
			%ScrollableTodoList/%TodoList/%Items._drop_data(
				999_999_999_999 * Vector2.ONE,
				data
			)
	)


func _connect_signals() -> void:
	#region Global Signals
	EventBus.today_changed.connect(_apply_date_relative_formating)

	Settings.view_mode_changed.connect(_on_view_mode_changed)

	EventBus.today_changed.connect(_update_date_offset)

	Settings.current_day_changed.connect(_update_stretch_ratio)

	Settings.fade_non_today_dates_changed.connect(_apply_date_relative_formating)

	Settings.current_day_changed.connect(_on_current_day_changed)

	Settings.view_mode_changed.connect(_on_current_day_changed)
	Settings.view_mode_cap_changed.connect(_on_current_day_changed)

	EventBus.bookmark_jump_requested.connect(func(bookmarked_date, bookmarked_line_number):
		if date and date.equals(bookmarked_date):
			%ScrollableTodoList.get_node("%TodoList").edit_line(
				bookmarked_line_number
			)
	)
	#endregion

	#region Local Signals
	%Header.gui_input.connect(_on_header_gui_input)
	%Header.mouse_entered.connect(_on_header_mouse_entered)
	%Header.mouse_exited.connect(_on_header_mouse_exited)
	#endregion


func _update_stretch_ratio() -> void:
	if date.as_dict() == Settings.current_day.as_dict():
		size_flags_stretch_ratio = 1.5
	else:
		size_flags_stretch_ratio = 1.0


func _update_header() -> void:
	if date:
		%Date.text = date.format("MMM DD, YYYY")
		%Weekday.text = date.format("dddd")
	else:
		%Date.text = "MMM DD, YYYY"
		%Weekday.text = "WEEKDAY"
	_update_date_offset()
	_apply_date_relative_formating()


func _update_date_offset() -> void:
	if date:
		var day_offset := date.day_difference_to(DayTimer.today)
		if day_offset == -1:
			%DayOffset.text = "Yesterday"
		elif day_offset == 0:
			%DayOffset.text = "TODAY"
		elif day_offset == 1:
			%DayOffset.text = "Tomorrow"
		elif day_offset < 0:
			%DayOffset.text = "%d days ago" % abs(day_offset)
		elif day_offset > 0:
			%DayOffset.text = "in %d days" % abs(day_offset)
	else:
		%DayOffset.text = ""


func _apply_date_relative_formating() -> void:
	if date:
		var day_difference := date.day_difference_to(DayTimer.today)

		if day_difference < 0:
			# date is in the past
			if Settings.fade_non_today_dates == Settings.FadeNonTodayDates.PAST or \
				Settings.fade_non_today_dates == Settings.FadeNonTodayDates.PAST_AND_FUTURE:
					$VBox.modulate.a = 0.4
			else:
				$VBox.modulate.a = 1.0
		elif day_difference == 0:
			# date is today
			$VBox.modulate.a = 1.0
		else:
			# date is in the future
			if Settings.fade_non_today_dates == Settings.FadeNonTodayDates.FUTURE or \
				Settings.fade_non_today_dates == Settings.FadeNonTodayDates.PAST_AND_FUTURE:
					$VBox.modulate.a = 0.4
			else:
				$VBox.modulate.a = 1.0
	else:
		# reset formatting
		modulate.a = 1.0


func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		if event.pressed and event.double_click:
			get_viewport().set_input_as_handled()
			# save previous state
			Settings.previous_day = Settings.current_day
			Settings.previous_view_mode = Settings.view_mode
			# zoom in on the double clicked date
			Settings.current_day = date
			Settings.view_mode = 1
			# unfocus the header
			_on_header_mouse_exited()


func _on_header_mouse_entered() -> void:
	if Settings.view_mode != 1:
		%Header.theme_type_variation = "DayPanel_Header_Selected"
		%Header.mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _on_header_mouse_exited() -> void:
	%Header.theme_type_variation = "DayPanel_Header"
	%Header.mouse_default_cursor_shape = CURSOR_ARROW


func _on_view_mode_changed() -> void:
	%Header/Tooltip.disabled = (Settings.view_mode == 1)


func _on_current_day_changed() -> void:
	var view_mode = min(Settings.view_mode, Settings.view_mode_cap)
	if view_mode != 1 and date.as_dict() == Settings.current_day.as_dict():
		theme_type_variation = "DayPanel_CurrentDay"
	else:
		theme_type_variation = "DayPanel"
