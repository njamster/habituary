extends MarginContainer

const TODO_ITEM := preload("todo_item/todo_item.tscn")


func add_todo(at_position : Vector2) -> void:
	var new_item := TODO_ITEM.instantiate()
	%Items.add_child(new_item)
	%Items.move_child(new_item, find_item_pos(at_position))
	new_item.create_follow_up.connect(func():
		add_todo(self.global_position + new_item.position + Vector2(0, 32))
	)
	new_item.edit()


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
