extends Control


var review_queue := []
var current_review_id := -1
var total_reviews_due := 0


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


func _setup_initial_state() -> void:
	_on_main_panel_changed()


func _connect_signals() -> void:
	#region Global Signals
	Settings.main_panel_changed.connect(_on_main_panel_changed)
	#endregion

	#region Local Signals
	%Schedule/Buttons/Today.pressed.connect(_schedule_current_item.bind(0))
	%Schedule/Buttons/Tomorrow.pressed.connect(_schedule_current_item.bind(1))

	%Postpone/Buttons/Tomorrow.pressed.connect(_postpone_current_item.bind(1))
	%Postpone/Buttons/NextWeek.pressed.connect(_postpone_current_item.bind(7))

	%SkipButton.pressed.connect(switch_to_list_view)
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
			).day_difference_to(DayTimer.today) >= 0:
				continue  # with next item

		# TODO: only if a review is due
		review_queue.append({ "to_do": to_do, "line_id": line_id })

	total_reviews_due = review_queue.size()

	if review_queue.is_empty():
		Settings.set_deferred("main_panel", Settings.MainPanelState.LIST_VIEW)
		return  # early

	_review_next_item()


func _review_next_item() -> void:
	current_review_id += 1
	if current_review_id < review_queue.size():
		%Progress.text = "Review %d of %d:" % [
			current_review_id + 1,
			total_reviews_due
		]
		%ToDo.text = Utils.strip_tags(review_queue[current_review_id].to_do)
	else:
		switch_to_list_view()


func _schedule_current_item(day_offset: int) -> void:
	Cache.move_item(
		review_queue[current_review_id].line_id,
		"capture",
		DayTimer.today.add_days(day_offset).as_string(),
	)
	_review_next_item()


func _postpone_current_item(day_offset: int) -> void:
	Cache.postpone_item(
		review_queue[current_review_id].line_id,
		"capture",
		DayTimer.today.add_days(day_offset).as_string(),
	)
	_review_next_item()


func switch_to_list_view() -> void:
	Settings.set_deferred("main_panel", Settings.MainPanelState.LIST_VIEW)
