extends PanelContainer

var date : Date:
	set(value):
		if date != null:  # once set, date becomes immutable
			return

		date = value

var store_path := ""  # set via _update_store_path() in _set_initial_state()

var is_dragged := false


func _ready() -> void:
	assert(date != null, "You must provide a date in order for this node to work!")

	_set_initial_state()
	_connect_signals()

	load_from_disk()


func _set_initial_state() -> void:
	_on_view_mode_changed()
	_update_stretch_ratio()
	_on_current_day_changed()

	_update_store_path()
	_update_header()


func _connect_signals() -> void:
	#region Global Signals
	EventBus.today_changed.connect(_apply_date_relative_formating)

	Settings.view_mode_changed.connect(_on_view_mode_changed)

	EventBus.today_changed.connect(_update_date_offset)

	Settings.current_day_changed.connect(_update_stretch_ratio)

	Settings.fade_non_today_dates_changed.connect(_apply_date_relative_formating)

	Settings.current_day_changed.connect(_on_current_day_changed)

	Settings.view_mode_changed.connect(func():
		_on_current_day_changed()
	)
	#endregion

	#region Local Signals
	date.changed.connect(_update_store_path)
	date.changed.connect(_update_header)

	# NOTE: `tree_exited` will be emitted both when this panel is removed from the tree because
	# the user scrolled the list'view, as well as on a NOTIFICATION_WM_CLOSE_REQUEST.
	tree_exited.connect(save_to_disk)
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	%Header.gui_input.connect(_on_header_gui_input)
	%Header.mouse_entered.connect(_on_header_mouse_entered)
	%Header.mouse_exited.connect(_on_header_mouse_exited)

	%ScrollContainer.gui_input.connect(_on_gui_input)

	%TodoList.list_save_requested.connect(save_to_disk)
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


func _update_store_path() -> void:
	store_path = Settings.store_path.path_join(
		self.date.format(Settings.date_format_save)
	) + ".txt"


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


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return %TodoList._can_drop_data(_at_position, data)


func _drop_data(at_position: Vector2, data: Variant) -> void:
	%TodoList._drop_data(at_position - %ScrollContainer.position, data)


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


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		if event.pressed:
			%TodoList.add_todo(event.global_position)


func save_to_disk() -> void:
	if not %TodoList.pending_save:
		return # early

	if %TodoList.has_items():
		var file := FileAccess.open(store_path, FileAccess.WRITE)
		%TodoList.save_to_disk(file)
	elif FileAccess.file_exists(store_path):
		DirAccess.remove_absolute(store_path)

	%TodoList.pending_save = false
	if OS.is_debug_build():
		# NOTE: This will *not* be printed when this function is called after `tree_exited` was
		# emitted. See: https://github.com/godotengine/godot/issues/90667
		print("[DEBUG] List Saved to Disk!")


func load_from_disk() -> void:
	if FileAccess.file_exists(store_path):
		%TodoList.load_from_disk(FileAccess.open(store_path, FileAccess.READ))


func _on_mouse_entered() -> void:
	$HoverTimer.timeout.connect(%TodoList.show_line_highlight.bind(get_global_mouse_position()))
	$HoverTimer.start()


func _on_mouse_exited() -> void:
	if $HoverTimer.is_stopped():
		%TodoList.hide_line_highlight()
	else:
		$HoverTimer.stop()
	$HoverTimer.timeout.disconnect(%TodoList.show_line_highlight)


func _on_header_mouse_entered() -> void:
	if Settings.view_mode != 1:
		%Header.theme_type_variation = "DayPanel_Header_Selected"
		%Header.mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _on_header_mouse_exited() -> void:
	%Header.theme_type_variation = "DayPanel_Header"
	%Header.mouse_default_cursor_shape = CURSOR_ARROW


func _on_view_mode_changed() -> void:
	if Settings.view_mode == 1:
		%Header/Tooltip.disabled = true
		%Header/Tooltip.hide_tooltip()
	else:
		%Header/Tooltip.disabled = false


func _on_current_day_changed() -> void:
	if Settings.view_mode != 1 and date.as_dict() == Settings.current_day.as_dict():
		theme_type_variation = "DayPanel_CurrentDay"
	else:
		theme_type_variation = "DayPanel"
