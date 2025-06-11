extends HBoxContainer

const DAY_PANEL := preload("day_panel/day_panel.tscn")

@onready var drag_cache := Node.new()


func _ready() -> void:
	add_child(drag_cache, false, Node.INTERNAL_MODE_FRONT)

	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	resized.connect(_on_resized)

	Settings.view_mode_changed.connect(_update_list_view)

	Settings.main_panel_changed.connect(func():
		visible = (Settings.main_panel == Settings.MainPanelState.LIST_VIEW)
	)
	_update_list_view()

	Settings.view_mode_cap_changed.connect(_update_list_view)

	Settings.current_day_changed.connect(_shift_list_view)
	#endregion


func _on_resized() -> void:
	var todolist_width : int = get_child(0).get_combined_minimum_size().x
	var separation := get_theme_constant("separation", "LargeSeparation")

	if size.x >= 7 * todolist_width + 6 * separation + 1:
		Settings.view_mode_cap = 7
	elif size.x >= 5 * todolist_width + 4 * separation + 1:
		Settings.view_mode_cap = 5
	elif size.x >= 3 * todolist_width + 2 * separation + 1:
		Settings.view_mode_cap = 3
	else:
		Settings.view_mode_cap = 1


func _update_list_view() -> void:
	var view_mode = min(Settings.view_mode, Settings.view_mode_cap)

	var child_count := get_child_count()

	# remove superfluous panels (if there are any)
	for i in range(view_mode, child_count):
		match Settings.today_position:
			Settings.TodayPosition.LEFTMOST:
				remove_day_panel(view_mode)
			Settings.TodayPosition.SECOND_PLACE:
				if i == 1:
					remove_day_panel(0)
				else:
					remove_day_panel(view_mode)
			Settings.TodayPosition.CENTERED:
				if i % 2 == 0:
					remove_day_panel(0)
				else:
					remove_day_panel(get_child_count() - 1)

	# add additonal panels (if it's necessary)
	for i in range(child_count, view_mode):
		match Settings.today_position:
			Settings.TodayPosition.LEFTMOST:
				add_day_panel(i)
			Settings.TodayPosition.SECOND_PLACE:
				if child_count == 1 and i == 1:
					add_day_panel(-1, true)
				else:
					add_day_panel(i - 1)
			Settings.TodayPosition.CENTERED:
				if i % 2 == 0:
					add_day_panel(-1 * floor(0.5 * i), true)
				else:
					add_day_panel(ceil(0.5 * i))


func _shift_list_view() -> void:
	var view_mode = min(Settings.view_mode, Settings.view_mode_cap)

	var today_offset := 0
	match Settings.today_position:
		Settings.TodayPosition.SECOND_PLACE:
			if get_child_count() > 1:
				today_offset = 1
		Settings.TodayPosition.CENTERED:
			today_offset = floor(0.5 * view_mode)

	var offset = Settings.current_day.day_difference_to(get_child(today_offset).date)
	offset = sign(offset) * min(abs(offset), view_mode)

	for i in abs(offset):
		if offset < 0:
			# remove superfluous panel on the right
			remove_day_panel(get_child_count() - 1)
		elif offset > 0:
			# remove superfluous panel on the left
			remove_day_panel(0)

		if offset < 0:
			# add additional panel on the left
			add_day_panel(abs(offset) - 1 - i - today_offset, true)
		elif offset > 0:
			# add additional panel on the right
			add_day_panel(Settings.view_mode - offset + i - today_offset)


func add_day_panel(offset_from_current_day : int, push_front := false) -> void:
	var day_panel_date := Settings.current_day.add_days(offset_from_current_day)

	var day_panel

	if drag_cache.get_children():
		if drag_cache.get_child(0).date.as_dict() == day_panel_date.as_dict():
			day_panel = drag_cache.get_child(0)
			day_panel.reparent(self)
			day_panel.show()

	if not day_panel:
		day_panel = DAY_PANEL.instantiate()
		day_panel.date = day_panel_date
		add_child(day_panel)

	if push_front:
		move_child(day_panel, 0)


func remove_day_panel(index : int) -> void:
	var day_panel = get_child(index)
	if day_panel.is_dragged:
		day_panel.reparent(drag_cache)
		day_panel.hide()
	else:
		day_panel.queue_free()
		remove_child(day_panel)


func _input(event: InputEvent) -> void:
	# If the user moves the mouse, make sure the cursor becomes visible again
	# (it automatically is hidden while typing in a to-do's text).
	if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
		if event is InputEventMouseMotion:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if drag_cache.get_children():
			var day_panel := drag_cache.get_child(0)
			drag_cache.remove_child(day_panel)
			day_panel.queue_free()
