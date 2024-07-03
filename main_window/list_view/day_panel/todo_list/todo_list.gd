extends MarginContainer

const TODO_ITEM := preload("todo_item/todo_item.tscn")


func _ready() -> void:
	if OS.is_debug_build():
		for i in range(4):
			var debug_item := TODO_ITEM.instantiate()
			debug_item.add_to_group("debug_item")
			debug_item.text = "Debug_%d" % i
			%Items.add_child(debug_item)
			if i == 0:
				debug_item.done = true
			elif i == 1:
				debug_item.is_heading = true


func add_todo(at_position := Vector2.ZERO) -> Control:
	var new_item := TODO_ITEM.instantiate()
	%Items.add_child(new_item)
	if at_position != Vector2.ZERO:
		%Items.move_child(new_item, find_item_pos(at_position))
	new_item.editing_finished.connect(func():
		get_parent().get_parent().save_to_disk()
	)
	new_item.create_follow_up.connect(func():
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
