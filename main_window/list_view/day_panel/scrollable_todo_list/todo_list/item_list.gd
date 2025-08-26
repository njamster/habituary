extends VBoxContainer


const MAX_INDENTATION_LEVEL := 3

var rejection_tween : Tween


#region Setup
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
			x_offset = get_child(0).indentation_level * \
				get_parent().get_theme_constant("margin_left")
		get_to_do_list().show_line_highlight(x_offset)
	)
	mouse_exited.connect(func():
		get_to_do_list().hide_line_highlight()
	)

	child_entered_tree.connect(_on_item_added)

	# Deferred, so the callback isn't called while the list is first loaded
	child_order_changed.connect.call_deferred(
		_on_items_child_order_changed
	)
	#endregion


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
			event.button_index == MOUSE_BUTTON_LEFT and \
					event.pressed:
		accept_event()

		var at_index := 0
		for child in get_children():
			if child.position.y > event.position.y - 13:
				break
			at_index += 1

		add_todo(at_index)
#endregion


#region Adding Items
func _on_item_added(item: Node) -> void:
	if item is not ToDoItem:
		return

	if name == "Items":
		item.indentation_level = 0
	elif name == "SubItems":
		item.indentation_level = get_node("../..").indentation_level + 1


func add_todo(at_index := -1, auto_edit := true) -> ToDoItem:
	# Add a new to-do item to the end of this item list.
	var new_item := preload("todo_item/todo_item.tscn").instantiate()
	add_child(new_item)

	# Then move it to the position indicated by [at_index].
	move_child(new_item, at_index)

	if auto_edit:
		new_item.edit.call_deferred()

	return new_item


func add_todo_above(item: ToDoItem, auto_edit := true) -> ToDoItem:
	return add_todo(item.get_index(), auto_edit)


func add_todo_below(item: ToDoItem, auto_edit := true) -> ToDoItem:
	return add_todo(item.get_index() + 1, auto_edit)


func add_sub_item(item: ToDoItem, auto_edit := true) -> ToDoItem:
	return item.get_node("%SubItems").add_todo(
		item.get_sub_item_count(),
		auto_edit
	)
#endregion


#region Moving Items
func move_todo_up(item: ToDoItem) -> void:
	var index := item.get_index()

	if index > 0:
		move_child(item,index - 1)
		if item.text:
			item.get_to_do_list()._start_debounce_timer("to-do moved")
	else:
		_reject_indentation_change(item, Vector2.UP)


func move_todo_down(item: ToDoItem) -> void:
	var index := item.get_index()

	if index < get_child_count() - 1:
		move_child(item, index + 1)
		if item.text:
			item.get_to_do_list()._start_debounce_timer("to-do moved")
	else:
		_reject_indentation_change(item, Vector2.DOWN)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# prevents the user from dropping a to-do on its own sub items
	return data is ToDoItem and not data.is_ancestor_of(self)


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var at_index := 0
	for child in get_children():
		if child == data:
			continue
		if child.position.y > at_position.y - 13:
			break
		else:
			at_index += 1

	var dragged_from = data.get_item_list()
	var old_list = data.get_to_do_list()

	if self.get_day_panel() and not data.get_day_panel():
		# data was part of the capture list before, but won't be anymore:
		# (a) remove review date
		data.review_date = ""
		# (b) repeat this for all of its sub items
		for sub_item in data.get_node("%SubItems").get_all_items():
			sub_item.review_date = ""
	elif not self.get_day_panel() and data.get_day_panel():
		# data will become part of the capture list now, but wasn't before:
		# (a) add review date
		var tomorrow = DayTimer.today.add_days(1).as_string()
		data.review_date = tomorrow
		# (b) remove bookmark
		data.is_bookmarked = false
		# (c) repeat this for all of its sub items
		for sub_item in data.get_node("%SubItems").get_all_items():
			sub_item.review_date = tomorrow
			sub_item.is_bookmarked = false

	if data.has_node("EditingOptions"):
		data.get_node("EditingOptions").update_bookmark.call_deferred()

	if dragged_from != self:
		data.reparent(self)
	move_child(data, at_index)

	if dragged_from != self:
		old_list._start_debounce_timer("to-do dragged to another list")
		data._update_saved_search_results(old_list.cache_key, data.text)

	if data.is_in_edit_mode():
		data.edit()

	data.get_to_do_list()._start_debounce_timer("to-do dropped")
	data._update_saved_search_results(data.get_to_do_list().cache_key, data.text)

	data._update_copy_to_today_visibility()
#endregion


#region Getting Items
func is_empty() -> bool:
	for child in get_children():
		if child is ToDoItem:
			return false

	return true


func get_all_items() -> Array[Node]:
	var result: Array[Node] = []

	for item in get_children():
		result.append(item)
		result += item.get_node("%SubItems").get_all_items()

	return result


func get_predecessor_todo(item: ToDoItem) -> ToDoItem:
	if item.get_index() > 0:
		# item has at least one item before it...
		var predecessor := get_child(item.get_index() - 1)
		var sub_item_count = predecessor.get_sub_item_count()
		if predecessor.get_node("%SubItems").visible and sub_item_count > 0:
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
	if item.get_node("%SubItems").visible and item.get_sub_item_count() > 0:
		# item has at least one sub item -> return that
		return item.get_sub_item(0)
	elif item.get_index() < get_child_count() - 1:
		# item has at least one item after it -> return that
		return get_child(item.get_index() + 1)
	elif name == "SubItems":
		# item is the final sub item of another item
		# -> return the item after that item (if there is any)
		return item.get_to_do_list().get_item_for_line_number(
			item.get_list_index() + 1
		)

	return null  # no successor


func get_item_for_line_number(target: int, start := 0) -> Variant:
	var i := start

	for to_do in get_children():
		if i == target:
			return to_do
		else:
			i += 1

		var result = to_do.get_node("%SubItems").get_item_for_line_number(target, i)
		if result is ToDoItem:
			return result
		else:
			i = result

	return i


func get_line_number_for_item(item: ToDoItem, start := 0) -> int:
	var i := start

	for to_do in get_children():
		if to_do == item:
			return i
		else:
			i += 1

		if to_do.has_sub_items():
			var result = to_do.get_node("%SubItems").get_line_number_for_item(item, i)
			if result >= 0:
				return result
			else:
				i = abs(result)

	return -i  # a negative return value means the item is not in this item list


func _on_items_child_order_changed() -> void:
	if is_inside_tree():
		for item in get_all_items():
			if not item.is_bookmarked:
				continue

			if not item.has_requested_bookmark_update:
				EventBus.bookmark_changed.emit.call_deferred(
					item,
					item.last_date,
					item.last_index
				)
				item.has_requested_bookmark_update = true

			item.last_index = item.get_list_index()
			item.last_date = item.date
#endregion


#region Indenting Items
func indent_todo(item: ToDoItem, visual_feedback := true) -> void:
	if item.get_index() == 0 or item.indentation_level == MAX_INDENTATION_LEVEL:
		if visual_feedback:
			_reject_indentation_change(item, Vector2.RIGHT)
		return  # first item in a list cannot be indented

	var predecessor_item := get_child(item.get_index() - 1)
	if predecessor_item.is_folded:
		predecessor_item.is_folded = false
	item.reparent(predecessor_item.get_node("%SubItems"))

	if item._initialization_finished:
		item.edit()

		if item.text:
			item.get_to_do_list()._start_debounce_timer(
				"indentation_level changed"
			)


func unindent_todo(item: ToDoItem, visual_feedback := true) -> void:
	var parent_todo := item.get_parent_todo()

	if not parent_todo:
		if visual_feedback:
			_reject_indentation_change(item, Vector2.LEFT)
		return  # item cannot be unindented any further

	item.reparent(parent_todo.get_item_list())
	item.get_parent().move_child(item, parent_todo.get_index() + 1)

	if item._initialization_finished:
		item.edit()

		if item.text:
			item.get_to_do_list()._start_debounce_timer(
				"indentation_level changed"
			)


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
