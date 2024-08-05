extends MarginContainer

const TODO_ITEM := preload("todo_item/todo_item.tscn")


func _ready() -> void:
	$LineHighlight.modulate.a = 0.0

	if OS.is_debug_build():
		for i in range(8):
			var debug_item := add_todo(Vector2.ZERO, true)
			debug_item.text = "Debug_%d" % i
			if i == 0:
				debug_item.done = true
			elif i == 1 or i == 5:
				debug_item.is_heading = true


func add_todo(at_position := Vector2.ZERO, is_debug_item := false) -> Control:
	var new_item := TODO_ITEM.instantiate()
	if is_debug_item:
		new_item.add_to_group("debug_item")
	%Items.add_child(new_item)
	if at_position != Vector2.ZERO:
		%Items.move_child(new_item, find_item_pos(at_position))
	connect_todo_signals(new_item)
	if at_position != Vector2.ZERO:
		new_item.edit()
	return new_item


func connect_todo_signals(todo_item : Control) -> void:
	todo_item.editing_started.connect(hide_line_highlight)
	todo_item.changed.connect(func():
		get_parent().get_parent().save_to_disk()
	)
	todo_item.predecessor_requested.connect(func():
		add_todo(self.global_position + todo_item.position - Vector2(0, 32))
	)
	todo_item.successor_requested.connect(func():
		add_todo(self.global_position + todo_item.position + Vector2(0, 32))
	)
	todo_item.folded.connect(func():
		fold_heading(todo_item.get_index(), false)
	)
	todo_item.unfolded.connect(func():
		fold_heading(todo_item.get_index(), true)
	)


func disconnect_todo_signals(todo_item : Control) -> void:
	var signal_names = [
		"editing_started",
		"changed",
		"predecessor_requested",
		"successor_requested",
		"folded",
		"unfolded"
	]
	for signal_name in signal_names:
		for sig in todo_item.get_signal_connection_list(signal_name):
			for dict2 in sig.signal.get_connections():
				sig.signal.disconnect(dict2.callable)


func find_item_pos(at_position : Vector2) -> int:
	var last_heading
	var inside_folded_heading := false
	for i in %Items.get_child_count():
		var child := %Items.get_child(i)
		if child.is_heading:
			inside_folded_heading = false
		if child.global_position.y > at_position.y:
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


func fold_heading(item_index : int, unfold := false) -> void:
	var heading := %Items.get_child(item_index)

	var num_items := 0
	var num_done := 0

	for i in range(item_index + 1, %Items.get_child_count()):
		var child := %Items.get_child(i)
		if child.is_heading:
			heading.set_extra_info(num_done, num_items)
			return
		else:
			child.visible = unfold
			num_items += 1
			if child.done:
				num_done += 1

	heading.set_extra_info(num_done, num_items)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Object:
		if data.has_method("is_in_group"):
			return data.is_in_group("todo_item")
	elif data is Array:
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
			entry.modulate.a = 1.0
			if entry.get_parent() != %Items:
				# item moved from one list to another
				disconnect_todo_signals(entry)
				entry.reparent(%Items)
				connect_todo_signals(entry)
				%Items.move_child(entry, base_position + i)
			else:
				# item changed its position inside the list
				if base_position >= entry.get_index() - i and \
					base_position <= entry.get_index() + data.size() - i:
						# new position _is_ the previous position
						continue
				elif entry.get_index() < base_position:
					# new position is _below_ the previous position
					%Items.move_child(entry, base_position - 1)
				else:
					# new position is _above_ the previous position
					%Items.move_child(entry, min(%Items.get_child_count(), base_position + i))


func has_items() -> bool:
	for child in %Items.get_children():
		if not child.is_in_group("debug_item"):
			return true
	return false


func save_to_disk(file : FileAccess) -> void:
	for child in %Items.get_children():
		if not child.is_in_group("debug_item"):
			child.save_to_disk(file)


func load_from_disk(file : FileAccess) -> void:
	while file.get_position() < file.get_length():
		var restored_item := add_todo()
		restored_item.load_from_disk(file.get_line())


func show_line_highlight(mouse_position : Vector2) -> void:
	# base assumption: list is empty -> put the line at the top of the list
	var y_position = %Items.global_position.y

	# if the list has any visible items, put the line below the last one of those
	for i in range(%Items.get_child_count() - 1, -1, -1):
		var child := %Items.get_child(i)
		if child.visible:
			y_position = child.global_position.y + child.size.y + %Items.get("theme_override_constants/separation")
			break

	# if the mouse cursor is above that last visible item, find the item that is closest to the
	# current mouse cursor position and put the line there
	for i in %Items.get_child_count():
		var child := %Items.get_child(i)
		if child.global_position.y > mouse_position.y:
			y_position = child.global_position.y
			break

	$LineHighlight.global_position.y = y_position - \
		0.5 * %Items.get("theme_override_constants/separation")
	if y_position == %Items.global_position.y:
		$LineHighlight.position.y += 0.5 * $LineHighlight.custom_minimum_size.y
	else:
		$LineHighlight.position.y -= 0.5 * $LineHighlight.custom_minimum_size.y
	$LineHighlight.modulate.a = 1.0


func hide_line_highlight() -> void:
	$LineHighlight.modulate.a = 0.0


func _on_line_highlight_item_rect_changed() -> void:
	$LineHighlight.modulate.a = 0.0


func _on_item_rect_changed() -> void:
	# note: this feels like something that should be handled in the theme, but currently cannot...
	if self.size.y > get_parent().size.y:
		# vertical scrollbar is visible, add some padding on the right side
		add_theme_constant_override("margin_right", 8)
	else:
		# vertical scrollbar isn't visible (anymore), remove padding (again)
		add_theme_constant_override("margin_right", 0)


func get_subordinate_items(item_index : int) -> Array:
	var subordinate_items := []

	for i in range(item_index + 1, %Items.get_child_count()):
		var child := %Items.get_child(i)
		if child.is_heading:
			return subordinate_items
		else:
			subordinate_items.append(child)

	return subordinate_items
