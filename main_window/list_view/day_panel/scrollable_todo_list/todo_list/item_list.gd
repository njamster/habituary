extends VBoxContainer


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		accept_event()

		var at_index := 0
		for child in get_children():
			if child.position.y > event.position.y - 13:
				break
			at_index += 1

		add_todo(at_index)


func add_todo(at_index := -1, auto_edit := true) -> ToDoItem:
	var new_item := preload("todo_item/todo_item.tscn").instantiate()
	add_child(new_item)

	move_child(new_item, clamp(at_index, -get_child_count(), get_child_count()))

	if at_index > 0:
		var predecessor := get_child(at_index - 1)
		if predecessor.has_sub_items() or predecessor.text.ends_with(":"):
			indent_todo(new_item)

	if auto_edit:
		new_item.edit()

	return new_item


func add_todo_above(item: ToDoItem) -> void:
	add_todo(item.get_index())


func add_todo_below(item: ToDoItem) -> void:
	add_todo(item.get_index() + 1)


func move_todo_up(item: ToDoItem) -> void:
	move_child(item, max(item.get_index() - 1, 0))


func move_todo_down(item: ToDoItem) -> void:
	move_child(item, item.get_index() + 1)


func get_predecessor_todo(item: ToDoItem) -> ToDoItem:
	if item.get_index() > 0:
		# item has at least one item before it...
		var predecessor := get_child(item.get_index() - 1)
		var sub_item_count = predecessor.get_sub_item_count()
		if sub_item_count > 0:
			# ... if that item has any sub items -> return the last of them
			return predecessor.get_sub_item(sub_item_count - 1)
		else:
			# ... otherwise -> return the item itself
			return predecessor
	elif name == "SubItems":
		# item is the first sub item of another item -> return that item
		return item.get_parent_todo()

	return null  # no predecessor


func get_successor_todo(item: ToDoItem) -> ToDoItem:
	if item.get_sub_item_count() > 0:
		# item has at least one sub item -> return that
		return item.get_sub_item(0)
	elif item.get_index() < get_child_count() - 1:
		# item has at least one item after it -> return that
		return get_child(item.get_index() + 1)
	elif name == "SubItems":
		# item is the final sub item of another item -> return the item after
		# that item (if there is any)
		if item.get_parent_todo().get_item_list().get_child_count() > \
				item.get_parent_todo().get_index() + 1:
					return item.get_parent_todo().get_item_list().get_child(
						item.get_parent_todo().get_index() + 1
					)

	return null  # no successor


func indent_todo(item: ToDoItem) -> void:
	if item.get_index() == 0 or item.indentation_level == 3:
		_reject_indentation_change(item, +1)
		return  # first item in a list cannot be indented

	var predecessor_item := get_child(item.get_index() - 1)
	if predecessor_item.is_folded:
		predecessor_item.is_folded = false
	item.reparent(predecessor_item.get_node("%SubItems"))

	item.indentation_level += 1

	if item._initialization_finished:
		item.edit()

		if item.text:
			item.get_to_do_list()._start_debounce_timer(
				"indentation_level changed"
			)


func unindent_todo(item: ToDoItem) -> void:
	var parent_todo := item.get_parent_todo()

	if not parent_todo:
		_reject_indentation_change(item, -1)
		return  # item cannot be unindented any further

	item.reparent(parent_todo.get_item_list())
	item.get_parent().move_child(item, parent_todo.get_index() + 1)

	item.indentation_level -= 1

	if item._initialization_finished:
		item.edit()

		if item.text:
			item.get_to_do_list()._start_debounce_timer(
				"indentation_level changed"
			)


## Play a short animation to indicate a rejected indentation request.
func _reject_indentation_change(item: ToDoItem, direction: int) -> void:
	var tween := create_tween()
	var main_row := item.get_node("%MainRow")
	tween.tween_property(main_row, "position:x", direction * 5, 0.03)
	tween.tween_property(main_row, "position:x",  0, 0.03)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ToDoItem


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data.is_ancestor_of(self):
		return  # prevent the user from dropping a to-do on its own sub items

	var at_index := 0
	for child in get_children():
		if child == data:
			continue
		if child.position.y > at_position.y - 13:
			break
		at_index += 1

	var dragged_from = data.get_item_list()
	var old_list = data.get_to_do_list()

	#var old_index = data.get_index()
	#if entry.is_bookmarked:
		#var old_date = entry.date
		#entry.last_index = base_position + i
		#entry.reparent(%Items)
		#EventBus.bookmark_changed.emit(entry, old_date, old_index)
	#else:
		#entry.reparent(%Items)

	if dragged_from != self:
		data.reparent(self)

	move_child(data, at_index)

	if at_index > 0:
		var predecessor := get_child(at_index - 1)
		if predecessor.has_sub_items() or predecessor.text.ends_with(":"):
			indent_todo(data)

	if dragged_from != self:
		old_list._start_debounce_timer("to-do dragged to another list")

	if data.is_in_edit_mode():
		data.edit()

	data.get_to_do_list()._start_debounce_timer("to-do dropped")


func is_empty() -> bool:
	return get_child_count() == 0
