extends VBoxContainer


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
