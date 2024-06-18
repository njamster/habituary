extends HBoxContainer

const DAY_PANEL := preload("res://day_panel/day_panel.tscn")


func _ready() -> void:
	_update_list_view(Settings.view_mode)

	EventBus.view_mode_changed.connect(_update_list_view)
	EventBus.current_day_changed.connect(_shift_list_view)


func _update_list_view(view_mode : int) -> void:
	var child_count := get_child_count()

	# remove superfluous panels (if there are any)
	for i in range(view_mode, child_count):
		remove_day_panel(i)

	# add additonal panels (if it's necessary)
	for i in range(child_count, view_mode):
		add_day_panel(i)


func _shift_list_view(current_day : Date) -> void:
	var offset = current_day.day_difference(get_child(0).date)

	if abs(offset) >= Settings.view_mode:
		for i in get_child_count():
			remove_day_panel(i)
		for i in Settings.view_mode:
			add_day_panel(i)
		return

	for i in abs(offset):
		if offset < 0:
			# remove superfluous panels on the right
			remove_day_panel(get_child_count() - 1 - i)
		elif offset > 0:
			# remove superfluous panels on the left
			remove_day_panel(i)

	for i in abs(offset):
		if offset < 0:
			var day_panel := add_day_panel(abs(offset) - 1 - i)
			move_child(day_panel, 0)
		elif offset > 0:
			add_day_panel(Settings.view_mode - 1 + i)


# FIXME: make day panels their own class?
func add_day_panel(offset_from_current_day : int) -> Control:
	var day_panel := DAY_PANEL.instantiate()
	day_panel.date = Settings.current_day.add_days(offset_from_current_day)
	# TODO: load panel content from disk
	add_child(day_panel)
	return day_panel


func remove_day_panel(index : int) -> void:
	# TODO: save panel content to disk
	get_child(index).queue_free()
