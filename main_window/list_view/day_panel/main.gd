@tool
extends PanelContainer

@export var date : Date:
	set(value):
		date = value
		_update_store_path()
		if is_inside_tree():
			_update_header()
			if value:
				date.changed.connect(_update_header)
				date.changed.connect(_update_store_path)

var store_path := ""

var is_dragged := false


func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(date != null, "You must provide a date in order for this node to work!")

	_update_header()

	if not Engine.is_editor_hint():
		_update_store_path()
		load_from_disk()

		%TodoList.list_save_requested.connect(save_to_disk)
		# NOTE: `tree_exited` will be emitted both when this panel is removed from the tree because
		# the user scrolled the list'view, as well as on a NOTIFICATION_WM_CLOSE_REQUEST.
		self.tree_exited.connect(save_to_disk)
		EventBus.today_changed.connect(_apply_date_relative_formating)
		_on_dark_mode_changed(Settings.dark_mode)
		EventBus.dark_mode_changed.connect(_on_dark_mode_changed)
		EventBus.view_mode_changed.connect(_on_view_mode_changed)
		_on_view_mode_changed(Settings.view_mode)
		EventBus.today_changed.connect(_update_date_offset)

		EventBus.current_day_changed.connect(_update_stretch_ratio)
		_update_stretch_ratio(Settings.current_day)

		EventBus.fade_non_today_dates_changed.connect(_apply_date_relative_formating)

		EventBus.current_day_changed.connect(_on_current_day_changed)
		EventBus.view_mode_changed.connect(func(_x):
			_on_current_day_changed(Settings.current_day)
		)
		_on_current_day_changed(Settings.current_day)


func _update_stretch_ratio(current_day : Date) -> void:
	if date.as_dict() == current_day.as_dict():
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
			%Weekday.remove_theme_color_override("font_color")
		elif day_difference == 0:
			# date is today
			$VBox.modulate.a = 1.0
			%Weekday.add_theme_color_override("font_color", Settings.NORD_09)
		else:
			# date is in the future
			if Settings.fade_non_today_dates == Settings.FadeNonTodayDates.FUTURE or \
				Settings.fade_non_today_dates == Settings.FadeNonTodayDates.PAST_AND_FUTURE:
					$VBox.modulate.a = 0.4
			else:
				$VBox.modulate.a = 1.0
			%Weekday.remove_theme_color_override("font_color")
	else:
		# reset formatting
		modulate.a = 1.0
		%Weekday.remove_theme_color_override("font_color")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not date:
		warnings.append("You must provide a date in order for this node to work!")
	return warnings


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
		%Header.get("theme_override_styles/panel").draw_center = true
		%Header.mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _on_header_mouse_exited() -> void:
	%Header.get("theme_override_styles/panel").draw_center = false
	%Header.mouse_default_cursor_shape = CURSOR_ARROW


func _on_dark_mode_changed(dark_mode : bool) -> void:
	if dark_mode:
		%Header.get("theme_override_styles/panel").bg_color = Settings.NORD_02
	else:
		%Header.get("theme_override_styles/panel").bg_color = Settings.NORD_04


func _on_view_mode_changed(view_mode : int) -> void:
	if view_mode == 1:
		%Header/Tooltip.disabled = true
		%Header/Tooltip.hide_tooltip()
	else:
		%Header/Tooltip.disabled = false


func _on_current_day_changed(current_day: Date) -> void:
	if Settings.view_mode != 1 and date.as_dict() == current_day.as_dict():
		theme_type_variation = "DayPanel_CurrentDay"
	else:
		theme_type_variation = "DayPanel"
