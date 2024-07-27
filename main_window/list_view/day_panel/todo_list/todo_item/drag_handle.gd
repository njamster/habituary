extends TextureRect

@onready var host := get_parent().get_parent().get_parent()

var nodes_to_move := []


func _get_drag_data(_at_position: Vector2) -> Variant:
	if host.done:
		return

	var items = VBoxContainer.new()
	items.size.x = host.get_parent().size.x

	nodes_to_move = [host]
	if host.is_heading:
		nodes_to_move += host.get_parent().get_parent().get_parent().get_subordinate_items(host.get_index())

	for node in nodes_to_move:
		var preview = node.duplicate()
		var stylebox = preview.get("theme_override_styles/panel").duplicate()
		stylebox.draw_center = node.is_heading
		preview.set("theme_override_styles/panel", stylebox)
		items.add_child(preview)

	var pivot = Control.new()
	items.position = -get_parent().position - position - 0.5 * size
	pivot.add_child(items)
	set_drag_preview(pivot)

	for node in nodes_to_move:
		node.modulate.a = 0.4
	get_node("Tooltip").hide_tooltip()

	return nodes_to_move


func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_END:
		if not get_viewport().gui_is_drag_successful():
			for node in nodes_to_move:
				node.modulate.a = 1.0
