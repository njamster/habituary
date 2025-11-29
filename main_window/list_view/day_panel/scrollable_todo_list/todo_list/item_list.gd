extends VBoxContainer


const MAX_INDENTATION_LEVEL := 3


var indentation_level := 0

var rejection_tween : Tween

var data: ToDoListData:
	set(value):
		if data != null:
			for item in %Items.get_children():
				item.queue_free()
		data = value

		for to_do_data in data.to_dos:
			add_todo(-1, false, to_do_data)

		data.to_do_added.connect(func(to_do_data, at_index, auto_edit):
			add_todo(at_index, auto_edit, to_do_data)
		)
		data.to_do_removed.connect(func(at_index):
			get_child(at_index).queue_free()
		)


#region Setup
func _enter_tree() -> void:
	if name == "SubItems":
		indentation_level = get_node("../../..").indentation_level + 1


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Local Signals
	gui_input.connect(_on_gui_input)

	mouse_entered.connect(func():
		if get_viewport().gui_is_dragging():
			if not _can_drop_data(
					get_local_mouse_position(),
					get_viewport().gui_get_drag_data()
				):
					return  # early

		var x_offset := 0
		if name == "SubItems" and get_child_count():
			x_offset = indentation_level * \
				get_parent().get_theme_constant("margin_left")
		get_to_do_list().show_line_highlight(x_offset)
	)
	mouse_exited.connect(func():
		get_to_do_list().hide_line_highlight()
	)
	#endregion


func _on_gui_input(event: InputEvent) -> void:
	if (
		event.is_action_released("left_mouse_button")
		and Utils.is_mouse_cursor_above(self)
	):
		var at_index := 0
		for child in get_children():
			if child.position.y > event.position.y - 13:
				break
			at_index += 1
		data.add(ToDoData.new(), at_index, true)
#endregion


#region Adding Items
func add_todo(at_index := -1, auto_edit := true, p_data: ToDoData = null) -> ToDoItem:
	# Add a new to-do item to the end of this item list.
	var new_item := preload("todo_item/todo_item.tscn").instantiate()
	add_child(new_item)

	# Then move it to the position indicated by [at_index].
	move_child(new_item, at_index)

	if not p_data:
		p_data = ToDoData.new()
		data.add(p_data, at_index)
	new_item.data = p_data

	if auto_edit:
		new_item.edit.call_deferred()

	return new_item


func add_todo_above(item: ToDoItem, auto_edit := true) -> void:
	data.add(ToDoData.new(), item.get_index(), auto_edit)


func add_todo_below(item: ToDoItem, auto_edit := true) -> void:
	data.add(ToDoData.new(), item.get_index() + 1, auto_edit)


func add_sub_item(item: ToDoItem, auto_edit := true) -> ToDoItem:
	return item.get_node("%SubItems").data.add(
		ToDoData.new(),
		item.get_sub_item_count(),
		auto_edit
	)
#endregion


#region Moving Items
func move_todo_up(item: ToDoItem) -> void:
	var index := item.get_index()

	if index > 0:
		move_child(item, index - 1)
		if item.text:
			data.move(item.data, index - 1)
	else:
		_reject_indentation_change(item, Vector2.UP)


func move_todo_down(item: ToDoItem) -> void:
	var index := item.get_index()

	if index < get_child_count() - 1:
		move_child(item, index + 1)
		if item.text:
			data.move(item.data, index + 1)
	else:
		_reject_indentation_change(item, Vector2.DOWN)


func _can_drop_data(_at_position: Vector2, p_data: Variant) -> bool:
	# prevents the user from dropping a to-do on its own sub items
	return p_data is ToDoItem and not p_data.is_ancestor_of(self)


func _drop_data(at_position: Vector2, p_data: Variant) -> void:
	var at_index := 0
	for child in get_children():
		if child == p_data:
			continue
		if child.position.y > at_position.y - 13:
			break
		else:
			at_index += 1

	var dragged_from = p_data.get_item_list()

	if self.get_day_panel() and not p_data.get_day_panel():
		# p_data was part of the capture list before, but won't be anymore:
		# (a) remove review date
		p_data.review_date = ""
		# (b) repeat this for all of its sub items
		for sub_item in p_data.get_node("%SubItems").get_all_items():
			sub_item.review_date = ""
	elif not self.get_day_panel() and p_data.get_day_panel():
		# p_data will become part of the capture list now, but wasn't before:
		# (a) add review date
		var tomorrow = DayTimer.today.add_days(1).as_string()
		p_data.review_date = tomorrow
		# (b) repeat this for all of its sub items
		for sub_item in p_data.get_node("%SubItems").get_all_items():
			sub_item.review_date = tomorrow

	dragged_from.data.remove(p_data.data)
	data.add(p_data.data, at_index, p_data.is_in_edit_mode())

	p_data._update_copy_to_today_visibility()
#endregion


#region Getting Items
func get_all_items() -> Array[Node]:
	var result: Array[Node] = []

	for item in get_children():
		result.append(item)
		result += item.get_node("%SubItems").get_all_items()

	return result
#endregion


#region Indenting Items
func indent_todo(item: ToDoItem, visual_feedback := true) -> void:
	if item.get_index() == 0 or indentation_level == MAX_INDENTATION_LEVEL:
		if visual_feedback:
			_reject_indentation_change(item, Vector2.RIGHT)
		return  # first item in a list cannot be indented

	var predecessor_item := get_child(item.get_index() - 1)
	if predecessor_item.is_folded:
		predecessor_item.is_folded = false
	item.reparent(predecessor_item.get_node("%SubItems"))

	data.indent(item.data)
	item.edit()


func unindent_todo(item: ToDoItem, visual_feedback := true) -> void:
	var parent_todo := item.get_parent_todo()

	if not parent_todo:
		if visual_feedback:
			_reject_indentation_change(item, Vector2.LEFT)
		return  # item cannot be unindented any further

	item.reparent(parent_todo.get_item_list())
	item.get_parent().move_child(item, parent_todo.get_index() + 1)

	data.unindent(item.data)
	item.edit()


## Plays a short animation to indicate a rejected indentation/move request.
func _reject_indentation_change(item: ToDoItem, direction: Vector2) -> void:
	if rejection_tween and rejection_tween.is_valid():
		return  # early (and let the old tween finish)
	rejection_tween = create_tween()

	# forward motion:
	rejection_tween.tween_property(
		item,
		"position",
		+5 * direction,
		0.03
	).as_relative()
	# backward motion:
	rejection_tween.tween_property(
		item,
		"position",
		-5 * direction,
		0.03
	).as_relative()
#endregion


#region Helper Functions
func get_to_do_list() -> ToDoList:
	var parent := get_parent()
	while parent is not ToDoList and parent != null:
		parent = parent.get_parent()
	return parent


func get_day_panel() -> ToDoList:
	var parent := get_parent()
	while parent is not DayPanel and parent != null:
		parent = parent.get_parent()
	return parent
#endregion
