class_name DayPanel
extends PanelContainer


const MODULATION_REGULAR := 1.0
const MODULATION_FADED_OUT := 0.4


var date: Date:
	set(value):
		if date != null:
			Log.error("Cannot set 'date': Variable is immutable!")
			return  # early
		date = value

var day_offset := 0

var is_dragged := false


func _ready() -> void:
	assert(
		date != null,
		"You must set the 'date' variable before adding this node to the tree!"
	)

	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	var filename := date.format(Settings.date_format_save)
	%ScrollableTodoList/%TodoList.data = Data.get_file(filename)

	_update_header()
	_update_header_tooltip_visibility()
	_update_theme_type_variation()
	_update_stretch_ratio()

	%Header.set_drag_forwarding(
		Callable(),  # unused, no forwarding required
		%ScrollableTodoList/%TodoList/%Items._can_drop_data,
		func(_at_position: Vector2, data: Variant):
			# Adds the dragged data to the end of the item list
			%ScrollableTodoList/%TodoList/%Items._drop_data(
				Utils.MAX_INT * Vector2.DOWN,
				data
			)
	)


func _connect_signals() -> void:
	#region Global Signals
	EventBus.today_changed.connect(_update_day_offset)

	Settings.fade_non_today_dates_changed.connect(_update_fade_out)

	Settings.view_mode_changed.connect(_update_header_tooltip_visibility)
	Settings.view_mode_cap_changed.connect(_update_header_tooltip_visibility)

	Settings.current_day_changed.connect(_on_current_day_changed)

	Settings.view_mode_changed.connect(_update_theme_type_variation)
	Settings.view_mode_cap_changed.connect(_update_theme_type_variation)
	#endregion

	#region Local Signals
	%Header.gui_input.connect(_on_header_gui_input)
	%Header.mouse_entered.connect(_focus_header)
	%Header.mouse_exited.connect(_unfocus_header)
	#endregion


func _update_header() -> void:
	%Date.text = date.format("MMM DD, YYYY")
	%Weekday.text = date.format("dddd")
	_update_day_offset()


func _update_day_offset() -> void:
	day_offset = date.day_difference_to(DayTimer.today)

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

	_update_fade_out()


func _update_fade_out() -> void:
	$VBox.modulate.a = MODULATION_REGULAR

	if Settings.fade_non_today_dates == Settings.FadeNonTodayDates.NONE:
		return  # early

	if day_offset < 0:
		if Settings.fade_non_today_dates in [
			Settings.FadeNonTodayDates.PAST,
			Settings.FadeNonTodayDates.PAST_AND_FUTURE
		]:
			$VBox.modulate.a = MODULATION_FADED_OUT
	elif day_offset > 0:
		if Settings.fade_non_today_dates in [
			Settings.FadeNonTodayDates.FUTURE,
			Settings.FadeNonTodayDates.PAST_AND_FUTURE
		]:
			$VBox.modulate.a = MODULATION_FADED_OUT


func _update_header_tooltip_visibility() -> void:
	var view_mode = min(Settings.view_mode, Settings.view_mode_cap)
	%Header/Tooltip.disabled = (view_mode == 1)


func _on_current_day_changed() -> void:
	_update_theme_type_variation()
	_update_stretch_ratio()


func _update_theme_type_variation() -> void:
	var view_mode = min(Settings.view_mode, Settings.view_mode_cap)
	if view_mode != 1 and date.equals(Settings.current_day):
		theme_type_variation = "DayPanel_CurrentDay"
	else:
		theme_type_variation = "DayPanel"


func _update_stretch_ratio() -> void:
	if date.equals(Settings.current_day):
		size_flags_stretch_ratio = 1.5
	else:
		size_flags_stretch_ratio = 1.0


func _on_header_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_button") and event.double_click:
		get_viewport().set_input_as_handled()

		# save previous state
		Settings.previous_day = Settings.current_day
		Settings.previous_view_mode = Settings.view_mode
		# zoom in on the double clicked date
		Settings.current_day = date
		Settings.view_mode = 1

		_unfocus_header()


func _focus_header() -> void:
	var view_mode = min(Settings.view_mode, Settings.view_mode_cap)
	if view_mode != 1:
		%Header.theme_type_variation = "DayPanel_Header_Selected"
		%Header.mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _unfocus_header() -> void:
	%Header.theme_type_variation = "DayPanel_Header"
	%Header.mouse_default_cursor_shape = CURSOR_ARROW
