class_name ToDoList
extends MarginContainer


signal list_save_requested

const TODO_ITEM := preload("todo_item/todo_item.tscn")

var pending_save := false


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	hide_line_highlight()


func _connect_signals() -> void:
	#region Parent Signals
	get_scroll_container().scrolled.connect(
		_start_debounce_timer.bind("list scrolled")
	)
	#endregion

	#region Local Signals
	item_rect_changed.connect(hide_line_highlight)

	%Items.child_order_changed.connect(_on_items_child_order_changed)

	$DebounceTimer.timeout.connect(func():
		if OS.is_debug_build():
			print("[DEBUG] DebounceTimer Timed Out: Saving List...")
		list_save_requested.emit()
	)
	#endregion


func _start_debounce_timer(reason := "Unknown"):
	if OS.is_debug_build():
		print("[DEBUG] List Save Requested: (Re)Starting DebounceTimer... (Reason: %s)" % reason)
	pending_save = true
	# If the DebounceTimer at this point is not inside the tree anymore, then this list is about to
	# exit the tree and starting this timer wouldn't work, as it's no longer part of the scene tree.
	# The parent day panel will issue a save anyway, though, as long as pending_save is true.
	if $DebounceTimer.is_inside_tree():
		$DebounceTimer.start()


func save_to_disk(file : FileAccess) -> void:
	for child in %Items.get_children():
		child.save_to_disk(file)

	var scroll_offset : int = get_scroll_container().scroll_vertical
	if scroll_offset != 0:
		file.store_line("SCROLL:%d" % scroll_offset)


func load_from_disk(file : FileAccess) -> void:
	while file.get_position() < file.get_length():
		var next_line := file.get_line()
		if next_line.begins_with("SCROLL:"):
			var scroll_offset := int(next_line.right(-7))
			# ensure that the scroll offset is a multiple of the height of one row in the list
			const ROW_HEIGHT := 40.0 # FIXME: avoid magic numbers...
			scroll_offset = int(round(scroll_offset / ROW_HEIGHT) * ROW_HEIGHT)
			# FIXME: the following works, but is rather hacky...
			await get_tree().process_frame
			await get_tree().process_frame
			get_scroll_container().set("scroll_vertical", scroll_offset)
		else:
			var restored_item = %Items.add_todo(-1, false)
			restored_item.load_from_disk(next_line)


func show_line_highlight(mouse_position: Vector2) -> void:
	%LineHighlight.modulate.a = 1.0

	var row_height = %Lines.get_combined_minimum_size().y
	var local_mouse_position = mouse_position.y - %Items.global_position.y
	var line_position = row_height * round(local_mouse_position / row_height)

	# NOTE: The -2 offset centers the highlight vertically along the line.
	%LineHighlight.position.y = clamp(
		line_position - 2,
		0,
		$Items.get_combined_minimum_size().y
	) + $Offset.get_theme_constant("margin_top")


func hide_line_highlight() -> void:
	%LineHighlight.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if Rect2(global_position, size).has_point(event.global_position):
			if self.is_ancestor_of(get_viewport().gui_get_hovered_control()):
				EventBus.todo_list_clicked.emit()


func _on_items_child_order_changed() -> void:
	if is_inside_tree():
		for item in %Items.get_children():
			if item.is_bookmarked:
				EventBus.bookmark_changed.emit.call_deferred(item, item.date, item.last_index)
				item.last_index = item.get_index()


func get_scroll_container() -> ScrollContainer:
	var parent := get_parent()
	while parent is not ScrollContainer and parent != null:
		parent = parent.get_parent()
	return parent
