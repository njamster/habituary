extends MarginContainer

const TODO_ITEM := preload("todo_item/todo_item.tscn")


func _ready() -> void:
	$LineHighlight.modulate.a = 0.0

	if OS.is_debug_build():
		for i in range(5):
			var debug_item := add_todo(Vector2.ZERO, true)
			debug_item.text = "Debug_%d" % i
			if i == 0:
				debug_item.done = true
			elif i == 1:
				debug_item.is_heading = true


func add_todo(at_position := Vector2.ZERO, is_debug_item := false) -> Control:
	var new_item := TODO_ITEM.instantiate()
	if is_debug_item:
		new_item.add_to_group("debug_item")
	%Items.add_child(new_item)
	if at_position != Vector2.ZERO:
		%Items.move_child(new_item, find_item_pos(at_position))
	new_item.editing_started.connect(hide_line_highlight)
	new_item.changed.connect(func():
		get_parent().get_parent().save_to_disk()
	)
	new_item.predecessor_requested.connect(func():
		add_todo(self.global_position + new_item.position - Vector2(0, 32))
	)
	new_item.successor_requested.connect(func():
		add_todo(self.global_position + new_item.position + Vector2(0, 32))
	)
	if at_position != Vector2.ZERO:
		new_item.edit()
	return new_item


func find_item_pos(at_position : Vector2) -> int:
	for i in %Items.get_child_count():
		var child := %Items.get_child(i)
		if child.global_position.y > at_position.y:
			return i

	return %Items.get_child_count()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.is_in_group("todo_item")


func _drop_data(at_position: Vector2, data: Variant) -> void:
	data.modulate.a = 1.0
	if data.get_parent() != %Items:
		data.reparent(%Items)
	%Items.move_child(data, find_item_pos(self.global_position + at_position))


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
	var i := find_item_pos(mouse_position)

	# don't highlight lines directly adjacent to the currently edited todo
	#if (i > 0 and %Items.get_child(i-1).is_in_edit_mode() or \
		#i < %Items.get_child_count() and %Items.get_child(i).is_in_edit_mode()):
			#return

	$LineHighlight.position.y = i * 40
	if i > 0:
		$LineHighlight.position.y -= 0.5 * $LineHighlight.custom_minimum_size.y
	$LineHighlight.modulate.a = 1.0


func hide_line_highlight() -> void:
	$LineHighlight.modulate.a = 0.0


func _on_line_highlight_item_rect_changed() -> void:
	$LineHighlight.modulate.a = 0.0
