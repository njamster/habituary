extends HBoxContainer

const DAY_PANEL := preload("day_panel/day_panel.tscn")


func _ready() -> void:
	_update_list_view(Settings.view_mode)

	EventBus.view_mode_changed.connect(_update_list_view)
	EventBus.current_day_changed.connect(_shift_list_view)


func _update_list_view(view_mode : int) -> void:
	var child_count := get_child_count()

	# remove superfluous panels (if there are any)
	for i in range(view_mode, child_count):
		remove_day_panel(view_mode)

	# add additonal panels (if it's necessary)
	for i in range(child_count, view_mode):
		add_day_panel(i)


func _shift_list_view(current_day : Date) -> void:
	var offset = current_day.day_difference_to(get_child(0).date)
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
			add_day_panel(abs(offset) - 1 - i, true)
		elif offset > 0:
			# add additional panel on the right
			add_day_panel(Settings.view_mode - offset + i)


func add_day_panel(offset_from_current_day : int, push_front := false) -> void:
	var day_panel := DAY_PANEL.instantiate()
	day_panel.date = Settings.current_day.add_days(offset_from_current_day)
	# TODO: load panel content from disk
	add_child(day_panel)
	if push_front:
		move_child(day_panel, 0)


func remove_day_panel(index : int) -> void:
	var day_panel = get_child(index)
	remove_child(day_panel)
	# TODO: save panel content to disk
	day_panel.queue_free()
