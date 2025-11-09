class_name ToDoList
extends MarginContainer


const TODO_ITEM := preload("todo_item/todo_item.tscn")

var data: FileData:
	set(value):
		if data:
			Log.error("Cannot set 'data': Variable is immutable!")
			return
		data = value

		load_data()


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	hide_line_highlight()

	var spacer = Control.new()
	spacer.name = "Spacer"
	spacer.custom_minimum_size.y = 13
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	%Items.add_child(spacer, true, Node.INTERNAL_MODE_BACK)


func _connect_signals() -> void:
	#region Parent Signals
	get_scroll_container().scrolled.connect(func():
		data.scroll_offset = get_scroll_container().scroll_vertical
	)
	#endregion

	#region Local Signals
	item_rect_changed.connect(hide_line_highlight)
	#endregion


func load_data() -> void:
	if not data:
		return  # early

	%Items.data = data.to_do_list

	if data.scroll_offset:
		await get_tree().process_frame  # wait for container size update
		get_scroll_container().scroll_vertical = data.scroll_offset


func show_line_highlight(x_offset: int) -> void:
	var row_height = %Lines.get_combined_minimum_size().y
	var local_mouse_position = get_local_mouse_position().y
	var line_position = row_height * round(local_mouse_position / row_height)

	%LineHighlight.position.x = x_offset
	# NOTE: The -2 offset centers the highlight vertically along the line.
	%LineHighlight.position.y = clamp(
		line_position - 2,
		0,
		$Items.get_combined_minimum_size().y - %Items.get_node("Spacer").get_combined_minimum_size().y
	) + $Offset.get_theme_constant("margin_top")

	%LineHighlight.modulate.a = 1.0


func hide_line_highlight() -> void:
	%LineHighlight.modulate.a = 0.0


func get_scroll_container() -> ScrollContainer:
	var parent := get_parent()
	while parent is not ScrollContainer and parent != null:
		parent = parent.get_parent()
	return parent


func edit_line(line_id: int) -> void:
	var result = %Items.get_item_for_line_number(line_id)
	if result is ToDoItem:
		result.edit()


func get_line_number_for_item(item: ToDoItem) -> int:
	return %Items.get_line_number_for_item(item)


func get_item_for_line_number(line_number: int) -> ToDoItem:
	var result = %Items.get_item_for_line_number(line_number)
	if result is ToDoItem:
		return result
	else:
		return null
