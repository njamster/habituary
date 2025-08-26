extends Node

# Godot uses signed 64-bit integers
const MIN_INT := -2**63
const MAX_INT :=  2**63 - 1


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


# FIXME: This is almost identical to the strip_text function in todo_item.gd –
# maybe there's a way to refactor things in a way that allows merging both?
func strip_tags(line: String) -> String:
	# trim any leading & trailing whitespace
	line = line.strip_edges()

	# remove checkbox
	line = line.right(-4).strip_edges()

	# Check if the text contains any tags (like a bookmark or a color tag) or
	# markup (like asterisks or underscores), and if so, trigger their effect
	# and then remove them from the text.
	while true:
		if line.ends_with("[BOOKMARK]"):
			line = line.left(-10).strip_edges()
			continue  # from the start of the while loop again

		var color_tag_reg_ex := RegEx.new()
		color_tag_reg_ex.compile("\\[COLOR(?<digit>[1-5])\\]$")
		var color_tag_reg_ex_match := color_tag_reg_ex.search(line)
		if color_tag_reg_ex_match:
			line = line.substr(0, line.length() - 9).strip_edges()
			continue  # from the start of the while loop again

		var review_date_reg_ex := RegEx.new()
		review_date_reg_ex.compile("\\[REVIEW:(?<date>[0-9]{4}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01]))\\]$")
		var review_date_reg_ex_match := review_date_reg_ex.search(line)
		if review_date_reg_ex_match:
			line = line.substr(0, line.length() - 20).strip_edges()
			continue  # from the start of the while loop again

		# NOTE: The following two if-conditions do *not* check if the matching
		# parts in the beginning and end of the raw text are distinct. This is
		# intended! It will also strip *any* number of asterisks or underscores
		# when the raw text only contains those and nothing else.

		if line.begins_with("**") and line.ends_with("**") or \
			line.begins_with("__") and line.ends_with("__"):
				line = line.left(-2).right(-2).strip_edges()
				continue  # from the start of the while loop again

		if line.begins_with("*") and line.ends_with("*") or \
			line.begins_with("_") and line.ends_with("_"):
				line = line.left(-1).right(-1).strip_edges()
				continue  # from the start of the while loop again

		break  # the while loop, nothing to replace was found anymore

	return line


func is_mouse_cursor_above(node: Node) -> bool:
	var mousePos = get_viewport().get_mouse_position()
	return node.get_global_rect().has_point(mousePos)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var orphan_count := Performance.get_monitor(
			Performance.OBJECT_ORPHAN_NODE_COUNT
		)
		if orphan_count:
			print_rich(
				"[color=red]%d orphan nodes at exit![/color]" % orphan_count
			)
