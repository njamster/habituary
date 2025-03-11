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


func add_todo(at_position := Vector2.ZERO) -> Control:
	var new_item := TODO_ITEM.instantiate()
	%Items.add_child(new_item)
	if at_position != Vector2.ZERO:
		%Items.move_child(new_item, find_item_pos(at_position))
	connect_todo_signals(new_item)
	if at_position != Vector2.ZERO:
		# deferred to wait for the container to update the item's position
		new_item.edit.call_deferred()
	return new_item


func _start_debounce_timer(reason := "Unknown"):
	if OS.is_debug_build():
		print("[DEBUG] List Save Requested: (Re)Starting DebounceTimer... (Reason: %s)" % reason)
	pending_save = true
	# If the DebounceTimer at this point is not inside the tree anymore, then this list is about to
	# exit the tree and starting this timer wouldn't work, as it's no longer part of the scene tree.
	# The parent day panel will issue a save anyway, though, as long as pending_save is true.
	if $DebounceTimer.is_inside_tree():
		$DebounceTimer.start()


func connect_todo_signals(todo_item : Control) -> void:
	todo_item.editing_started.connect(hide_line_highlight)
	todo_item.list_save_requested.connect(_start_debounce_timer)
	todo_item.predecessor_requested.connect(func():
		var predecessor := add_todo(self.global_position + todo_item.position - Vector2(0, 32))
		predecessor.indentation_level = todo_item.indentation_level
	)
	todo_item.successor_requested.connect(func():
		var successor := add_todo(self.global_position + todo_item.position + Vector2(0, 32))
		successor.indentation_level = todo_item.indentation_level
	)
	todo_item.folded.connect(func():
		fold_heading(todo_item.get_index(), false)
	)
	todo_item.unfolded.connect(func():
		fold_heading(todo_item.get_index(), true)
	)
	todo_item.moved_up.connect(func():
		move_to_do(todo_item, -1)
	)
	todo_item.moved_down.connect(func():
		move_to_do(todo_item, +1)
	)


func disconnect_todo_signals(todo_item : Control) -> void:
	var signal_names = [
		"editing_started",
		"list_save_requested",
		"predecessor_requested",
		"successor_requested",
		"folded",
		"unfolded",
		"moved_up",
		"moved_down",
	]
	for signal_name in signal_names:
		for sig in todo_item.get_signal_connection_list(signal_name):
			for dict2 in sig.signal.get_connections():
				sig.signal.disconnect(dict2.callable)


func move_to_do(item, offset : int) -> void:
	if offset == 0:
		return

	var MOVED_DOWN := (offset > 0)
	var MOVED_UP := not MOVED_DOWN

	var old_index = item.get_index()
	var PREDECESSOR_IDS := range(old_index - 1, -1, -1)
	var SUCCESSOR_IDS := range(old_index + 1, %Items.get_child_count())

	var new_index := -1
	if MOVED_DOWN:
		for successor_id in SUCCESSOR_IDS:
			var successor = %Items.get_child(successor_id)
			if successor.indentation_level == item.indentation_level:
				if offset:
					new_index = successor_id
					offset -= 1
				else:
					break
			elif successor.indentation_level > item.indentation_level:
				if offset == 0:
					# successor is a sub item of this item's successor
					new_index += 1
				continue
			else:
				break  # end of scope reached
	elif MOVED_UP:
		for predecessor_id in PREDECESSOR_IDS:
			var predecessor = %Items.get_child(predecessor_id)
			if predecessor.indentation_level == item.indentation_level:
				if offset:
					new_index = predecessor_id
					offset += 1
				else:
					break
			elif predecessor.indentation_level > item.indentation_level:
				# predecessor is a sub item of this item's predecessor
				continue
			else:
				break  # start of scope reached

	if new_index != -1:
		var sub_item_count := 0
		for successor_id in SUCCESSOR_IDS:
			var successor = %Items.get_child(successor_id)
			if successor.indentation_level > item.indentation_level:
				sub_item_count += 1
			else:
				break

		%Items.move_child(item, new_index)

		if MOVED_DOWN:
			for i in sub_item_count:
				%Items.move_child(%Items.get_child(old_index), new_index)
		elif MOVED_UP:
			for i in sub_item_count:
				%Items.move_child(%Items.get_child(old_index + i + 1), new_index + i + 1)

	self._start_debounce_timer("to-do moved")


func find_item_pos(at_position : Vector2) -> int:
	var last_heading = null
	var inside_folded_heading := false
	for i in %Items.get_child_count():
		var child := %Items.get_child(i)
		if not child.visible:
			continue
		if child.is_heading:
			inside_folded_heading = false
		if child.global_position.y >= at_position.y:
			if not inside_folded_heading:
				if last_heading:
					last_heading.get_node("%FoldHeading").button_pressed = false
				return i
		if child.is_heading:
			inside_folded_heading = child.is_folded
			if inside_folded_heading:
				last_heading = child
			else:
				last_heading = null

	if inside_folded_heading:
		if last_heading:
			last_heading.get_node("%FoldHeading").button_pressed = false

	return %Items.get_child_count()


func fold_heading(item_index: int, unfold := false) -> void:
	var heading := %Items.get_child(item_index)

	var num_items := 0
	var num_done := 0

	for child in get_subordinate_items(item_index):
		if unfold:
			if Settings.hide_ticked_off_todos:
				if child.state == child.States.TO_DO or \
					child._has_unticked_sub_todos():
						child.show()
			else:
				child.show()
				if child.is_heading and child.is_folded:
					fold_heading.call_deferred(child.get_index())
		else:
			child.is_folded = true
			child.hide()

		if not child.is_heading:
			num_items += 1
			if child.state != child.States.TO_DO:
				num_done += 1

	heading.set_extra_info(num_done, num_items)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Array:
		for entry in data:
			if entry.has_method("is_in_group"):
				if not entry.is_in_group("todo_item"):
					return false
			else:
				return false
		return true

	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Array:
		var base_position := find_item_pos(self.global_position + at_position)
		for i in data.size():
			var entry = data[i]

			var old_index = entry.get_index()

			# Now, move the entry to its new loation.
			if entry.get_item_list() != %Items:
				# item moved from one list to another
				var old_list = entry.get_to_do_list()
				disconnect_todo_signals(entry)
				if entry.is_bookmarked:
					var old_date = entry.date
					entry.last_index = base_position + i
					entry.reparent(%Items)
					EventBus.bookmark_changed.emit(entry, old_date, old_index)
				else:
					entry.reparent(%Items)
				connect_todo_signals(entry)
				%Items.move_child(entry, base_position + i)
				old_list._start_debounce_timer("to-do dragged to another list")
				if entry.is_in_edit_mode():
					entry.edit()
			else:
				# item changed its position inside the list
				if base_position >= old_index - i and \
					base_position <= old_index + data.size() - i:
						# new position _is_ the previous position
						continue
				elif old_index < base_position:
					# new position is _below_ the previous position
					%Items.move_child(entry, base_position - 1)
				else:
					# new position is _above_ the previous position
					%Items.move_child(entry, min(%Items.get_child_count(), base_position + i))

		# Re-trigger the setter of the first entries indentation_level to adjust it if necessary.
		data[0].indentation_level = data[0].indentation_level

		self._start_debounce_timer("to-do dropped")


func has_items() -> bool:
	return %Items.get_child_count() > 0


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
			var restored_item := add_todo()
			restored_item.load_from_disk(next_line)


func show_line_highlight(mouse_position: Vector2) -> void:
	$LineHighlight.show()

	# As LineHighlight is the child of a container node, we have to wait one
	# frame until Godot allows changing its position again.
	await get_tree().process_frame

	var row_height = $Lines.get_combined_minimum_size().y
	var local_mouse_position = mouse_position.y - %Items.global_position.y
	var line_position = row_height * round(local_mouse_position / row_height)

	# NOTE: The -2 offset centers the highlight vertically along the line.
	$LineHighlight.position.y = clamp(line_position - 2, 0, $Items.size.y)


func hide_line_highlight() -> void:
	$LineHighlight.hide()


func get_subordinate_items(item_index : int) -> Array:
	var subordinate_items := []

	var item := %Items.get_child(item_index)

	var has_sub_items := false
	if item_index + 1 < %Items.get_child_count():
		var child := %Items.get_child(item_index + 1)
		if child.indentation_level > item.indentation_level:
			has_sub_items = true

	for i in range(item_index + 1, %Items.get_child_count()):
		var child := %Items.get_child(i)

		if child.indentation_level < item.indentation_level:
			return subordinate_items
		elif has_sub_items or child.is_heading:
			if child.indentation_level == item.indentation_level:
				return subordinate_items

		subordinate_items.append(child)

	return subordinate_items


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


func get_nearest_visible_predecessor(index: int) -> Control:
	for i in range(index - 1, -1, -1):
		var predecessor := %Items.get_child(i)
		if predecessor.visible:
			return predecessor

	return null


func get_nearest_visible_successor(index: int) -> Control:
	for i in range(index + 1, %Items.get_child_count()):
		var successor := %Items.get_child(i)
		if successor.visible:
			return successor

	return null



func get_scroll_container() -> ScrollContainer:
	var parent := get_parent()
	while parent is not ScrollContainer and parent != null:
		parent = parent.get_parent()
	return parent
