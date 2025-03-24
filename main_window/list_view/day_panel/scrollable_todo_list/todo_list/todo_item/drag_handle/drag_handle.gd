extends Button


@onready var to_do: ToDoItem


func _ready() -> void:
	var parent := get_parent()
	while parent is not ToDoItem and parent != null:
		parent = parent.get_parent()
	to_do = parent


func _get_drag_data(_at_position: Vector2) -> Variant:
	var pivot = Control.new()

	# we only need a visually equivalent copy, not a functional one
	# that's why all DuplicateFlags are unset (== 0) here
	var preview = to_do.duplicate(0)
	to_do.modulate.a = 0.4
	if to_do.is_in_edit_mode():
		preview.get_node("EditingOptions").hide()
	preview.position = -1 * position
	preview.size.x = to_do.get_item_list().size.x
	pivot.add_child(preview)

	set_drag_preview(pivot)

	# Special case! Normally, this would be emitted on mouse button release, which makes sense
	# everywhere but here, where it should happen as soon as the user is starting to drag.
	EventBus.todo_list_clicked.emit()

	var day_panel := to_do.get_day_panel()
	if day_panel:
		day_panel.is_dragged = true

	return to_do


func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_END:
		to_do.modulate.a = 1.0
		var day_panel := to_do.get_day_panel()
		if day_panel:
			day_panel.is_dragged = false
