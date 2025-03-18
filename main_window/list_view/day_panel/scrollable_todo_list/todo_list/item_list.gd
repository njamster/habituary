extends VBoxContainer


const TODO_ITEM := preload("todo_item/todo_item.tscn")


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


func add_todo(at_index: int) -> void:
	var new_item := TODO_ITEM.instantiate()
	add_child(new_item)

	move_child(new_item, clamp(at_index, 0, get_child_count()))

	new_item.edit()


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
