extends Button


@onready var to_do: ToDoItem

var nodes_to_move := []


func _ready() -> void:
	var parent := get_parent()
	while parent is not ToDoItem and parent != null:
		parent = parent.get_parent()
	to_do = parent


func _get_drag_data(_at_position: Vector2) -> Variant:
	get_node("Tooltip").hide_tooltip()

	var items = VBoxContainer.new()
	items.add_theme_constant_override(
		"separation",
		to_do.get_item_list().get_theme_constant("separation")
	)
	items.size.x = to_do.get_item_list().size.x

	nodes_to_move = [to_do]
	if to_do.is_heading:
		nodes_to_move += to_do.get_to_do_list().get_subordinate_items(to_do.get_index())
	else:
		var todo_list := to_do.get_item_list()

		var SUCCESSOR_IDS := range(to_do.get_index() + 1, todo_list.get_child_count())
		for successor_id in SUCCESSOR_IDS:
			var successor = todo_list.get_child(successor_id)
			if successor.indentation_level > to_do.indentation_level:
				nodes_to_move.append(successor)
			else:
				break  # end of scope reached

	for node in nodes_to_move:
		# we only need a visually equivalent copy, not a functional one
		# that's why all DuplicateFlags are unset (== 0) here
		var preview = node.duplicate(0)
		items.add_child(preview)

		if node.is_in_edit_mode():
			preview.get_node("EditingOptions").hide()

	var pivot = Control.new()
	items.position = -1 * position
	pivot.add_child(items)
	set_drag_preview(pivot)

	for node in nodes_to_move:
		node.modulate.a = 0.4

	# Special case! Normally, this would be emitted on mouse button release, which makes sense
	# everywhere but here, where it should happen as soon as the user is starting to drag.
	EventBus.todo_list_clicked.emit()

	var day_panel := to_do.get_day_panel()
	if day_panel:
		day_panel.is_dragged = true

	return nodes_to_move


func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_END:
		for node in nodes_to_move:
			node.modulate.a = 1.0
		var day_panel := to_do.get_day_panel()
		if day_panel:
			day_panel.is_dragged = false
