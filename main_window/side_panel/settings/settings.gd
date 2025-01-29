extends VBoxContainer


func _ready() -> void:
	_set_initial_state()
	_connect_signals()

	for option_name in Settings.TodayPosition:
		var option_id : int = Settings.TodayPosition[option_name]
		%TodayPosition/Setting/Options.add_item(option_name.capitalize(), option_id)
		if option_id == Settings.today_position:
			%TodayPosition/Setting/Options.select(option_id)

	%FirstWeekday/Setting/Options.set_pressed_no_signal(Settings.start_week_on_monday)

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
	_set_text_colors()


func _set_text_colors() -> void:
	for i in range(5):
		var current_color = Settings.to_do_text_colors[i]
		%ToDoColors.get_node("Color%d/ColorPicker" % (i+1)).color = \
			current_color
		%ToDoColors.get_node("Color%d/Reset" % (i+1)).visible = \
			(current_color != Settings.DEFAULT_TO_DO_TEXT_COLORS[i])


func _connect_signals() -> void:
	#region Global Signals
	EventBus.to_do_text_colors_changed.connect(_set_text_colors)
	#endregion

	#region Local Signals
	%StorePath/Setting/Change.pressed.connect(_on_change_store_path_pressed)

	%TodayPosition/Setting/Options.item_selected.connect(_on_today_position_item_selected)

	%DayStart/Setting/Hours.value_changed.connect(_on_day_start_hours_value_changed)
	%DayStart/Setting/Minutes.value_changed.connect(_on_day_start_minutes_value_changed)

	%FirstWeekday/Setting/Options.toggled.connect(_on_first_weekday_toggled)

	%FadeTickedOffTodos/Setting/Options.toggled.connect(_on_fade_ticked_off_todos_options_toggled)

	%FadeNonTodayDates/Setting/Options.item_selected.connect(_on_fade_non_today_dates_options_item_selected)

	for i in range(5):
		%ToDoColors.get_node("Color%d/ColorPicker" % (i+1)).color_changed.connect(_on_todo_color_changed.bind(i))
		%ToDoColors.get_node("Color%d/Reset" % (i+1)).pressed.connect(_on_todo_color_reset.bind(i))
	#endregion


func _on_change_store_path_pressed() -> void:
	OS.shell_show_in_file_manager(Settings.store_path)


func _on_today_position_item_selected(index: int) -> void:
	Settings.today_position = Settings.TodayPosition[Settings.TodayPosition.keys()[index]]

	match index:
		Settings.TodayPosition.LEFTMOST:
			%TodayPosition/Explanation.text = \
				"After changing dates, the currently selected day will be displayed at the leftmost position of the list view."
		Settings.TodayPosition.SECOND_PLACE:
			%TodayPosition/Explanation.text = \
				"After changing dates, the currently selected day will be displayed at the second position of the list view."
		Settings.TodayPosition.CENTERED:
			%TodayPosition/Explanation.text = \
				"After changing dates, the currently selected day will be displayed at the center position of the list view."
		_:
			%TodayPosition/Explanation.text = ""


func _on_first_weekday_toggled(toggled_on: bool) -> void:
	Settings.start_week_on_monday = toggled_on

	if toggled_on:
		%FirstWeekday/Explanation.text = "New weeks in the calendar widget start on Mondays."
	else:
		%FirstWeekday/Explanation.text = "New weeks in the calendar widget start on Sundays."


func _on_day_start_hours_value_changed(value: float) -> void:
	Settings.day_start_hour_offset = int(value)


func _on_day_start_minutes_value_changed(value: float) -> void:
	Settings.day_start_minute_offset = int(value)


func _on_fade_ticked_off_todos_options_toggled(toggled_on: bool) -> void:
	Settings.fade_ticked_off_todos = toggled_on

	var explanation_text := "[fill]To-Dos that have been marked as done or " \
	+ "canceled {0} appear dimmed.[/fill]"
	if toggled_on:
		%FadeTickedOffTodos/Explanation.text = explanation_text.format([
			"will [u]not[/u]",
		])
	else:
		%FadeTickedOffTodos/Explanation.text = explanation_text.format([
			"will",
		])


func _on_fade_non_today_dates_options_item_selected(index: int) -> void:
	Settings.fade_non_today_dates = Settings.FadeNonTodayDates[
		Settings.FadeNonTodayDates.keys()[index]
	]

	var explanation_text := "[fill]List view columns that correspond to a " \
	+ "date in the {0} {1} appear dimmed.[/fill]"
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


func _on_todo_color_changed(color: Color, id: int) -> void:
	var new_colors = Settings.to_do_text_colors.duplicate()
	new_colors[id] = "#" + color.to_html(false).to_upper()
	Settings.to_do_text_colors = new_colors


func _on_todo_color_reset(id: int) -> void:
	var new_colors = Settings.to_do_text_colors.duplicate()
	new_colors[id] = Settings.DEFAULT_TO_DO_TEXT_COLORS[id]
	Settings.to_do_text_colors = new_colors
