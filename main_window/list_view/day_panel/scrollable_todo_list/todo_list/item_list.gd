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
	for i in range(item.get_index() - 1, -1, -1):
			var predecessor := get_child(i)
			if predecessor.visible:
				return predecessor

	return null  # no predecessor


func get_successor_todo(item: ToDoItem) -> ToDoItem:
	for i in range(item.get_index() + 1, get_child_count()):
		var successor := get_child(i)
		if successor.visible:
			return successor

	return null  # no successor


func indent_todo(item: ToDoItem) -> void:
	if item.get_index() == 0:
		_reject_indentation_change(item, +1)
		return  # first item in a list cannot be indented

	var predecessor_item := get_child(item.get_index() - 1)
	item.reparent(predecessor_item.get_node("%SubItems"))

	if item._initialization_finished:
		item.edit()

		if item.text:
			item.list_save_requested.emit("indentation_level changed")


func unindent_todo(item: ToDoItem) -> void:
	var parent_todo := item.get_parent_todo()

	if not parent_todo:
		_reject_indentation_change(item, -1)
		return  # item cannot be unindented any further

	item.reparent(parent_todo.get_item_list())
	item.get_parent().move_child(item, parent_todo.get_index() + 1)

	if item._initialization_finished:
		item.edit()

		if item.text:
			item.list_save_requested.emit("indentation_level changed")


## Play a short animation to indicate a rejected indentation request.
func _reject_indentation_change(item: ToDoItem, direction: int) -> void:
	var tween := create_tween()
	var main_row := item.get_node("%MainRow")
	tween.tween_property(main_row, "position:x", direction * 5, 0.03)
	tween.tween_property(main_row, "position:x",  0, 0.03)
