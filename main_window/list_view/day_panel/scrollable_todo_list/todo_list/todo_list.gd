class_name ToDoList
extends MarginContainer


const TODO_ITEM := preload("todo_item/todo_item.tscn")

var cache_key : String:
	set(value):
		if cache_key:  # once set, cache_key becomes immutable
			return

		cache_key = value

		load_from_cache(cache_key)

var pending_save := false


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	hide_line_highlight()

	var spacer = Control.new()
	spacer.name = "Spacer"
	spacer.custom_minimum_size.y = 13
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	%Items.add_child(spacer, true, Node.INTERNAL_MODE_BACK)


func _connect_signals() -> void:
	#region Global Signals
	Cache.content_updated.connect(func(key):
		if key == cache_key:
			for to_do in %Items.get_children():
				to_do.queue_free()

			load_from_cache(cache_key)
	)
	#endregion

	#region Parent Signals
	get_scroll_container().scrolled.connect(
		_start_debounce_timer.bind("list scrolled")
	)
	#endregion

	#region Local Signals
	item_rect_changed.connect(hide_line_highlight)

	$DebounceTimer.timeout.connect(func():
		if OS.is_debug_build():
			print("[DEBUG] DebounceTimer Timed Out: Saving List...")
			save_to_disk()
	)

	tree_exited.connect(save_to_disk)
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


func save_to_disk() -> void:
	if not pending_save:
		return # early

	var content = ""

	for child in %Items.get_children():
		content += child.as_string() + "\n"

	var scroll_offset : int = get_scroll_container().scroll_vertical
	if scroll_offset != 0:
		content += "SCROLL:%d" % scroll_offset

	Cache.update_content(cache_key, content.strip_edges(false, true))

	pending_save = false

	if OS.is_debug_build():
		# NOTE: This will *not* be printed when this function is called after `tree_exited` was
		# emitted. See: https://github.com/godotengine/godot/issues/90667
		print("[DEBUG] List Saved to Disk!")


func load_from_cache(key : String) -> void:
	if not key or key not in Cache.data:
		return  # early

	for line in Cache.data[key].content:
		if line.begins_with("SCROLL:"):
			var scroll_offset := int(line.right(-7))
			# ensure that the scroll offset is a multiple of the height of one row in the list
			const ROW_HEIGHT := 40.0 # FIXME: avoid magic numbers...
			scroll_offset = int(round(scroll_offset / ROW_HEIGHT) * ROW_HEIGHT)
			# FIXME: the following works, but is rather hacky...
			await get_tree().process_frame
			await get_tree().process_frame
			get_scroll_container().set("scroll_vertical", scroll_offset)
		else:
			var restored_item = %Items.add_todo(-1, false)
			restored_item.load_from_string(line)


func show_line_highlight(x_offset: int) -> void:
	var row_height = %Lines.get_combined_minimum_size().y
	var local_mouse_position = get_local_mouse_position().y
	var line_position = row_height * round(local_mouse_position / row_height)

	%LineHighlight.position.x = x_offset
	# NOTE: The -2 offset centers the highlight vertically along the line.
	%LineHighlight.position.y = clamp(
		line_position - 2,
		0,
		$Items.get_combined_minimum_size().y - %Items.get_node("Spacer").get_combined_minimum_size().y
	) + $Offset.get_theme_constant("margin_top")

	%LineHighlight.modulate.a = 1.0


func hide_line_highlight() -> void:
	%LineHighlight.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if Rect2(global_position, size).has_point(event.global_position):
			if self.is_ancestor_of(get_viewport().gui_get_hovered_control()):
				EventBus.todo_list_clicked.emit()


func get_scroll_container() -> ScrollContainer:
	var parent := get_parent()
	while parent is not ScrollContainer and parent != null:
		parent = parent.get_parent()
	return parent


func edit_line(line_id: int) -> void:
	var result = %Items.get_item_for_line_number(line_id)
	if result is ToDoItem:
		result.edit()


func get_line_number_for_item(item: ToDoItem) -> int:
	return %Items.get_line_number_for_item(item)


func get_item_for_line_number(line_number: int) -> ToDoItem:
	var result = %Items.get_item_for_line_number(line_number)
	if result is ToDoItem:
		return result
	else:
		return null
