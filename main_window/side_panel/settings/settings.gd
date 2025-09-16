extends VBoxContainer


func _ready() -> void:
	_set_initial_state()
	_connect_signals()

	$%DayStart/Setting/Hours.value = Settings.day_start_hour_offset
	$%DayStart/Setting/Minutes.value = Settings.day_start_minute_offset

	%FadeTickedOffTodos/Setting/Options.set_pressed_no_signal(Settings.fade_ticked_off_todos)
	_on_fade_ticked_off_todos_options_toggled(Settings.fade_ticked_off_todos)

	for option_name in Settings.FadeNonTodayDates:
		var option_id : int = Settings.FadeNonTodayDates[option_name]
		%FadeNonTodayDates/Setting/Options.add_item(option_name.capitalize(), option_id)
		if option_id == Settings.fade_non_today_dates:
			%FadeNonTodayDates/Setting/Options.select(option_id)
	_on_fade_non_today_dates_options_item_selected(Settings.fade_non_today_dates)


func _set_initial_state() -> void:
	%UIScale/Setting/ScaleFactor.min_value = Settings.MIN_UI_SCALE_FACTOR
	%UIScale/Setting/ScaleFactor.max_value = Settings.MAX_UI_SCALE_FACTOR
	%UIScale/Setting/ScaleFactor.value = Settings.ui_scale_factor

	%EnableCaptureReviews/Setting/Options.set_pressed_no_signal(
		Settings.enable_capture_reviews
	)
	_on_enable_capture_reviews_options_toggled(Settings.enable_capture_reviews)

	%FirstWeekday/Setting/Options.set_pressed_no_signal(
		Settings.start_week_on_monday
	)
	_on_first_weekday_toggled(Settings.start_week_on_monday)

	%OutsideMonthDates/Setting/Options.set_pressed_no_signal(
		Settings.show_outside_month_dates
	)
	_on_outside_month_dates_toggled(Settings.show_outside_month_dates)

	%HideTickedOffTodos/Setting/Options.set_pressed_no_signal(
		Settings.hide_ticked_off_todos
	)
	_on_hide_ticked_off_todos_options_toggled(Settings.hide_ticked_off_todos)

	for option_name in Settings.TodayPosition:
		var option_id : int = Settings.TodayPosition[option_name]
		%TodayPosition/Setting/Options.add_item(option_name.capitalize(), option_id)
		if option_id == Settings.today_position:
			%TodayPosition/Setting/Options.select(option_id)
			_on_today_position_item_selected(option_id)

	for option_name in Settings.ShowSubItemCount:
		var option_id : int = Settings.ShowSubItemCount[option_name]
		%ShowSubItemCount/Setting/Options.add_item(option_name.capitalize(), option_id)
		if option_id == Settings.show_sub_item_count:
			%ShowSubItemCount/Setting/Options.select(option_id)
			_on_show_sub_item_count_options_item_selected(option_id)

	_set_text_colors()

	%UseRelativeDates/Setting/Options.set_pressed_no_signal(
		Settings.use_relative_saved_search_dates
	)
	_on_use_relative_dates_options_toggled(
		Settings.use_relative_saved_search_dates
	)


func _set_text_colors() -> void:
	for i in range(5):
		var current_color = Settings.to_do_text_colors[i]
		%ToDoColors.get_node("Color%d/ColorPicker" % (i+1)).color = \
			current_color
		%ToDoColors.get_node("Color%d/Reset" % (i+1)).visible = \
			(current_color != Settings.DEFAULT_TO_DO_TEXT_COLORS[i])


func _connect_signals() -> void:
	#region Global Signals
	Settings.to_do_text_colors_changed.connect(_set_text_colors)
	#endregion

	#region Local Signals
	%StorePath/Setting/Change.pressed.connect(_on_change_store_path_pressed)

	%TodayPosition/Setting/Options.item_selected.connect(_on_today_position_item_selected)

	%DayStart/Setting/Hours.value_changed.connect(_on_day_start_hours_value_changed)
	%DayStart/Setting/Minutes.value_changed.connect(_on_day_start_minutes_value_changed)

	%EnableCaptureReviews/Setting/Options.toggled.connect(_on_enable_capture_reviews_options_toggled)

	%FirstWeekday/Setting/Options.toggled.connect(_on_first_weekday_toggled)

	%OutsideMonthDates/Setting/Options.toggled.connect(
		_on_outside_month_dates_toggled
	)

	%HideTickedOffTodos/Setting/Options.toggled.connect(_on_hide_ticked_off_todos_options_toggled)

	%FadeTickedOffTodos/Setting/Options.toggled.connect(_on_fade_ticked_off_todos_options_toggled)

	%FadeNonTodayDates/Setting/Options.item_selected.connect(_on_fade_non_today_dates_options_item_selected)

	for i in range(5):
		%ToDoColors.get_node("Color%d/ColorPicker" % (i+1)).color_changed.connect(_on_todo_color_changed.bind(i))
		%ToDoColors.get_node("Color%d/Reset" % (i+1)).pressed.connect(_on_todo_color_reset.bind(i))

	%ShowSubItemCount/Setting/Options.item_selected.connect(_on_show_sub_item_count_options_item_selected)

	%UIScale/Setting/ScaleFactor.value_changed.connect(func(value):
		Settings.ui_scale_factor = value
	)

	%UseRelativeDates/Setting/Options.toggled.connect(
		_on_use_relative_dates_options_toggled
	)
	#endregion


func _on_change_store_path_pressed() -> void:
	OS.shell_show_in_file_manager(Settings.store_path)


func _on_today_position_item_selected(index: int) -> void:
	Settings.today_position = Settings.TodayPosition[Settings.TodayPosition.keys()[index]]

	match index:
		Settings.TodayPosition.LEFTMOST:
			%TodayPosition/Explanation.text = (
				"After changing dates, the currently selected day will be"
				+ " displayed at the leftmost position."
			)
		Settings.TodayPosition.SECOND_PLACE:
			%TodayPosition/Explanation.text = (
				"After changing dates, the currently selected day will be"
				+ " displayed at the second position."
			)
		Settings.TodayPosition.CENTERED:
			%TodayPosition/Explanation.text = (
				"After changing dates, the currently selected day will be"
				+ " displayed at the center position."
			)
		_:
			%TodayPosition/Explanation.text = ""


func _on_first_weekday_toggled(toggled_on: bool) -> void:
	Settings.start_week_on_monday = toggled_on

	if toggled_on:
		%FirstWeekday/Explanation.text = (
			"New weeks in the calendar widget start on Mondays."
		)
	else:
		%FirstWeekday/Explanation.text = (
			"New weeks in the calendar widget start on Sundays."
		)


func _on_outside_month_dates_toggled(toggled_on: bool) -> void:
	Settings.show_outside_month_dates = toggled_on

	if toggled_on:
		%OutsideMonthDates/Explanation.text = (
			"If the current month doesn't start with the first or ends with the"
			+ " last day of the week, those gaps in the calendar widget will be"
			+ " filled up with dates from the previous or next month."
		)
	else:
		%OutsideMonthDates/Explanation.text = (
			"If the current month doesn't start with the first or ends with the"
			+ " last day of the week, those gaps in the calendar widget will be"
			+ " left empty."
		)


func _on_day_start_hours_value_changed(value: float) -> void:
	Settings.day_start_hour_offset = int(value)


func _on_day_start_minutes_value_changed(value: float) -> void:
	Settings.day_start_minute_offset = int(value)


func _on_enable_capture_reviews_options_toggled(toggled_on: bool) -> void:
	Settings.enable_capture_reviews = toggled_on


func _on_hide_ticked_off_todos_options_toggled(toggled_on: bool) -> void:
	Settings.hide_ticked_off_todos = toggled_on

	if toggled_on:
		%HideTickedOffTodos/Explanation.text = (
			"After marking a to-do as done or failed, it will slowly fade out"
			+ " and eventually disappear (unless it has sub items that are "
			+ " still unticked). Toggling the item's checkbox back will stop"
			+ " the process."
		)
		%FadeTickedOffTodos.hide()
	else:
		%HideTickedOffTodos/Explanation.text = (
			"To-Dos marked as done or failed won't disappear."
		)
		%FadeTickedOffTodos.show()


func _on_fade_ticked_off_todos_options_toggled(toggled_on: bool) -> void:
	Settings.fade_ticked_off_todos = toggled_on

	var explanation_text := (
		"To-Dos that have been marked as done or failed {0} appear dimmed."
		+ " (Only available while \"Hide Ticked Off To-Dos\" is disabled)"
	)
	if toggled_on:
		%FadeTickedOffTodos/Explanation.text = explanation_text.format([
			"will",
		])
	else:
		%FadeTickedOffTodos/Explanation.text = explanation_text.format([
			"will [u]not[/u]",
		])


func _on_fade_non_today_dates_options_item_selected(index: int) -> void:
	Settings.fade_non_today_dates = Settings.FadeNonTodayDates[
		Settings.FadeNonTodayDates.keys()[index]
	]

	var explanation_text := (
		"List view columns that correspond to a date in the {0} {1} appear"
		+ " dimmed."
	)
	match index:
		Settings.FadeNonTodayDates.NONE:
			%FadeNonTodayDates/Explanation.text = explanation_text.format([
				"past or future",
				"will [u]not[/u]",
			])
		Settings.FadeNonTodayDates.PAST:
			%FadeNonTodayDates/Explanation.text = explanation_text.format([
				"[b][i]past[/i][/b]",
				"will",
			])
		Settings.FadeNonTodayDates.FUTURE:
			%FadeNonTodayDates/Explanation.text = explanation_text.format([
				"[b][i]future[/i][/b]",
				"will",
			])
		Settings.FadeNonTodayDates.PAST_AND_FUTURE:
			%FadeNonTodayDates/Explanation.text = explanation_text.format([
				"[b][i]past or future [/i][/b]",
				"will",
			])
		_:
			%FadeNonTodayDates/Explanation.text = "" # this shouldn't happen


func _on_show_sub_item_count_options_item_selected(index: int) -> void:
	Settings.show_sub_item_count = Settings.ShowSubItemCount[
		Settings.ShowSubItemCount.keys()[index]
	]

	var explanation_text := (
		"To-Dos with (indented) sub items will {0} display the amount of their"
		+ " completed and total sub items in brackets to the right{1}."
	)
	match index:
		Settings.ShowSubItemCount.ALWAYS:
			%ShowSubItemCount/Explanation.text = explanation_text.format([
				"[u]always[/u] ",
				"",
			])
		Settings.ShowSubItemCount.WHEN_FOLDED:
			%ShowSubItemCount/Explanation.text = explanation_text.format([
				"",
				" [u]only[/u] while folded",
			])
		Settings.ShowSubItemCount.NEVER:
			%ShowSubItemCount/Explanation.text = explanation_text.format([
				"[u]never[/u] ",
				"",
			])
		_:
			%FadeNonTodayDates/Explanation.text = "" # this shouldn't happen


func _on_todo_color_changed(color: Color, id: int) -> void:
	var new_colors = Settings.to_do_text_colors.duplicate()
	new_colors[id] = "#" + color.to_html(false).to_upper()
	Settings.to_do_text_colors = new_colors


func _on_todo_color_reset(id: int) -> void:
	var new_colors = Settings.to_do_text_colors.duplicate()
	new_colors[id] = Settings.DEFAULT_TO_DO_TEXT_COLORS[id]
	Settings.to_do_text_colors = new_colors


func _on_use_relative_dates_options_toggled(toggled_on: bool) -> void:
	Settings.use_relative_saved_search_dates = toggled_on

	if toggled_on:
		%UseRelativeDates/Explanation.text = (
			"The \"Latest Match\" for a saved search will be shown relative to"
			+ " today, e.g. \"6 days ago\"."
		)
	else:
		%UseRelativeDates/Explanation.text = (
			"The \"Latest Match\" for a saved search will be shown as an"
			+ " absolute date, e.g. \"%s\"."
		) % DayTimer.today.add_days(-6).format("MMM DD, YYYY")
