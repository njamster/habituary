extends VBoxContainer

const TODO_ITEM := preload("res://main_window/list_view/day_panel/todo_item/todo_item.tscn")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT and event.pressed:
		var new_item := TODO_ITEM.instantiate()
		add_child(new_item)
		new_item.edit()


func _can_drop_data(_at_position: Vector2, data: Variant):
	return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.reparent(self)
