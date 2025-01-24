extends HBoxContainer

const DAY_PANEL := preload("day_panel/day_panel.tscn")

@onready var drag_cache := Node.new()


func _ready() -> void:
	add_child(drag_cache, false, Node.INTERNAL_MODE_FRONT)

	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	EventBus.view_mode_changed.connect(_update_list_view)
	_update_list_view(Settings.view_mode)

	EventBus.current_day_changed.connect(_shift_list_view)
	#endregion


func _update_list_view(view_mode : int) -> void:
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


func _shift_list_view(current_day : Date) -> void:
	var today_offset := 0
	match Settings.today_position:
		Settings.TodayPosition.SECOND_PLACE:
			if get_child_count() > 1:
				today_offset = 1
		Settings.TodayPosition.CENTERED:
			today_offset = floor(0.5 * Settings.view_mode)

	var offset = current_day.day_difference_to(get_child(today_offset).date)
	offset = sign(offset) * min(abs(offset), Settings.view_mode)

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
		remove_child(day_panel)
		day_panel.queue_free()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if drag_cache.get_children():
			var day_panel := drag_cache.get_child(0)
			drag_cache.remove_child(day_panel)
			day_panel.queue_free()
