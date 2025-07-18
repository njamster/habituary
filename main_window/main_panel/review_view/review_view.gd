extends Control


var review_queue := []
var current_review_id := -1
var total_reviews_due := 0
var scheduled_items := 0


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


func _setup_initial_state() -> void:
	_on_main_panel_changed()
	_on_dark_mode_changed()


func _connect_signals() -> void:
	#region Global Signals
	Settings.main_panel_changed.connect(_on_main_panel_changed)

	Settings.dark_mode_changed.connect(_on_dark_mode_changed)
	#endregion

	#region Local Signals
	$Mode.pressed.connect(_on_mode_pressed)

	%SkipButton.pressed.connect(switch_to_list_view)

	%Options/Schedule.pressed.connect(_show_schedule_calendar)
	%Options/Postpone.pressed.connect(_show_postpone_calendar)
	%Options/Delete.pressed.connect(_delete_current_item)
	%Options/Delete.mouse_exited.connect(_reset_delete_button)

	%Calendar/FirstRow/CloseButton.pressed.connect(_hide_calendar)
	#endregion

func _on_main_panel_changed() -> void:
	visible = (Settings.main_panel == Settings.MainPanelState.CAPTURE_REVIEW)

	if visible:
		_start_review()


func _start_review() -> void:
	if not "capture" in Cache.data:
		switch_to_list_view.call_deferred()
		return  # early

	review_queue = []
	current_review_id = -1

	var review_date_reg_ex := RegEx.new()
	review_date_reg_ex.compile("\\[REVIEW:(?<date>[0-9]{4}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01]))\\]")

	var line_id := -1
	for to_do in Cache.data["capture"].content:
		line_id += 1

		var review_date_reg_ex_match := review_date_reg_ex.search(to_do)
		if review_date_reg_ex_match:
			if Date.from_string(
				review_date_reg_ex_match.get_string("date")
			).day_difference_to(DayTimer.today) > 0:
				continue  # with next item

		review_queue.append({ "to_do": to_do, "line_id": line_id })

	total_reviews_due = review_queue.size()

	if review_queue.is_empty():
		Settings.set_deferred("main_panel", Settings.MainPanelState.LIST_VIEW)
		return  # early

	_review_next_item()


func _review_next_item() -> void:
	current_review_id += 1
	if current_review_id < review_queue.size():
		%Progress.text = "Item %d of %d:" % [
			current_review_id + 1,
			total_reviews_due
		]
		%ToDo.text = Utils.strip_tags(review_queue[current_review_id].to_do)
	else:
		switch_to_list_view()


func _schedule_current_item(date: Date) -> void:
	Cache.move_item(
		review_queue[current_review_id].line_id - scheduled_items,
		"capture",
		date.as_string()
	)
	scheduled_items += 1
	_hide_calendar(true)
	_review_next_item()


func _postpone_current_item(date: Date) -> void:
	Cache.postpone_item(
		review_queue[current_review_id].line_id,
		"capture",
		date.as_string()
	)
	_hide_calendar(true)
	_review_next_item()


func _delete_current_item() -> void:
	if %Options/Delete.text == "Delete":
		%Options/Delete.text = "Are you sure?"
		var style_box := StyleBoxFlat.new()
		style_box.bg_color = Color("#BF616A")
		%Options/Delete.add_theme_stylebox_override("hover", style_box)
	else:
		Cache.delete_item(
			review_queue[current_review_id].line_id,
			"capture"
		)
		_reset_delete_button()
		_review_next_item()


func switch_to_list_view() -> void:
	Settings.set_deferred("main_panel", Settings.MainPanelState.LIST_VIEW)


func _show_schedule_calendar() -> void:
	%Options.hide()
	%Calendar.show()
	%Calendar/FirstRow/Heading.text = "Schedule for…"
	%Calendar/Widget.day_button_tooltip = "Click to delay decision until this date"
	%Calendar/Widget.include_today = true

	if %Calendar/Widget.day_button_pressed.is_connected(_postpone_current_item):
		%Calendar/Widget.day_button_pressed.disconnect(_postpone_current_item)
	if not %Calendar/Widget.day_button_pressed.is_connected(_schedule_current_item):
		%Calendar/Widget.day_button_pressed.connect(
			_schedule_current_item
		)

	%Calendar/Widget.reset_view_to_today()


func _show_postpone_calendar() -> void:
	%Options.hide()
	%Calendar.show()
	%Calendar/FirstRow/Heading.text = "Ask again…"
	%Calendar/Widget.day_button_tooltip = "Click to move to-do to this date"
	%Calendar/Widget.include_today = false


	if %Calendar/Widget.day_button_pressed.is_connected(_schedule_current_item):
		%Calendar/Widget.day_button_pressed.disconnect(_schedule_current_item)
	if not %Calendar/Widget.day_button_pressed.is_connected(_postpone_current_item):
		%Calendar/Widget.day_button_pressed.connect(
			_postpone_current_item
		)

	%Calendar/Widget.reset_view_to_today()


func _hide_calendar(pause := false) -> void:
	%Calendar.hide()
	if pause:
		await get_tree().create_timer(0.5).timeout
	%Options.show()


func _reset_delete_button() -> void:
	%Options/Delete.text = "Delete"
	%Options/Delete.remove_theme_stylebox_override("hover")


func _on_mode_pressed() -> void:
	Settings.dark_mode = not Settings.dark_mode


func _on_dark_mode_changed() -> void:
	if Settings.dark_mode:
		$Mode.icon = preload("images/mode_light.svg")
		$Mode/Tooltip.text = "Switch To Light Mode"
	else:
		$Mode.icon = preload("images/mode_dark.svg")
		$Mode/Tooltip.text = "Switch To Dark Mode"
