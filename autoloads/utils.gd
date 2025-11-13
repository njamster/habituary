extends Node

# Godot uses signed 64-bit integers
const MIN_INT := -2**63
const MAX_INT :=  2**63 - 1


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		check_for_orphan_nodes()


func check_for_orphan_nodes() -> void:
	var orphan_count := Performance.get_monitor(
		Performance.OBJECT_ORPHAN_NODE_COUNT
	)
	if orphan_count:
		Log.warning("%d orphan nodes at exit!" % orphan_count)
		print_orphan_nodes()


func get_exported_properties(node: Node) -> Dictionary:
	var exported_properties := {}

	var current_group := "no_group"
	var current_group_prefix := ""
	for property in node.get_property_list():
		if property.usage & PROPERTY_USAGE_GROUP:
			current_group = property.name
			current_group_prefix = property.hint_string
		elif property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			if not property.name.begins_with(current_group_prefix):
				current_group = "no_group"
				current_group_prefix = ""

			if property.usage & PROPERTY_USAGE_STORAGE:
				if not exported_properties.has(current_group):
					exported_properties[current_group] = []

				exported_properties[current_group].append(property.name)

	return exported_properties


func is_mouse_cursor_above(node: Control, include_ancestors := true) -> bool:
	var hovered_control := get_viewport().gui_get_hovered_control()
	if not hovered_control:
		return false
	if hovered_control == node:
		return true
	if include_ancestors:
		return node.is_ancestor_of(hovered_control)
	return false


func is_action(event: InputEvent, exclude_built_in_actions := true) -> bool:
	var actions := InputMap.get_actions()

	if exclude_built_in_actions:
		actions = actions.filter(func(action) -> bool:
			return not action.begins_with("ui_")
		) as Array[StringName]

	for action in actions:
		if event.is_action(action, true):
			return true

	return false


func is_built_in_action(event: InputEvent, exact_match := true) -> bool:
	var actions := InputMap.get_actions().filter(func(action) -> bool:
		return action.begins_with("ui_")
	) as Array[StringName]

	for action in actions:
		if event.is_action(action, exact_match):
			return true

	return false


func shorten_string(input: String, width: int, placeholder := "...") -> String:
	if input.length() <= width:
		return input
	else:
		return input.left(width) + placeholder
