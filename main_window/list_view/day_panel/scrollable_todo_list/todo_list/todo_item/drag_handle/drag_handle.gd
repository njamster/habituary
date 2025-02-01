extends Button

@onready var host := get_node("../../..")

var nodes_to_move := []


func _get_drag_data(_at_position: Vector2) -> Variant:
	host._on_edit_text_submitted(host.get_node("%Edit").text, false)

	get_node("Tooltip").hide_tooltip()

	var items = VBoxContainer.new()
	items.add_theme_constant_override(
		"separation",
		host.get_parent().get_theme_constant("separation")
	)
	items.size.x = host.get_parent().size.x

	nodes_to_move = [host]
	if host.is_heading:
		nodes_to_move += host.get_node("../../..").get_subordinate_items(host.get_index())
	else:
		var todo_list := host.get_parent()

		var SUCCESSOR_IDS := range(host.get_index() + 1, todo_list.get_child_count())
		for successor_id in SUCCESSOR_IDS:
			var successor = todo_list.get_child(successor_id)
			if successor.indentation_level > host.indentation_level:
				nodes_to_move.append(successor)
			else:
				break  # end of scope reached

	for node in nodes_to_move:
		if node.is_in_edit_mode():
			node._on_edit_focus_exited()
		# we only need a visually equivalent copy, not a functional one
		# that's why all DuplicateFlags are unset (== 0) here
		var preview = node.duplicate(0)
		items.add_child(preview)

	var pivot = Control.new()
	items.position = -get_parent().position - position - 0.5 * size
	pivot.add_child(items)
	set_drag_preview(pivot)

	for node in nodes_to_move:
		node.modulate.a = 0.4

	# Special case! Normally, this would be emitted on mouse button release, which makes sense
	# everywhere but here, where it should happen as soon as the user is starting to drag.
	EventBus.todo_list_clicked.emit()

	host.get_node("../../../../..").is_dragged = true

	return nodes_to_move


func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_END:
		for node in nodes_to_move:
			node.modulate.a = 1.0
		host.get_node("../../../../..").is_dragged = false
