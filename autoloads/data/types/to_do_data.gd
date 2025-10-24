extends RefCounted
class_name ToDoData


signal indent_requested
signal delete_requested

signal changed


enum States {
	TO_DO,
	DONE,
	FAILED
}


var state := States.TO_DO:
	set(value):
		if state != value:
			state = value
			changed.emit()

var text: String:
	set(value):
		if text != value:
			text = value
			changed.emit()

var is_bold := false:
	set(value):
		if is_bold != value:
			is_bold = value
			changed.emit()

var is_italic := false:
	set(value):
		if is_italic != value:
			is_italic = value
			changed.emit()

var is_bookmarked := false:
	set(value):
		if is_bookmarked != value:
			is_bookmarked = value
			changed.emit()

var is_folded := false:
	set(value):
		if is_folded != value:
			is_folded = value
			changed.emit()

var text_color_id: int:
	set(value):
		if text_color_id != value:
			text_color_id = value
			changed.emit()

var sub_items: ToDoListData

var indentation_level := -1


func load_from_string(raw_string: String) -> void:
	while raw_string.begins_with("    "):
		raw_string = raw_string.right(-4)
		indent_requested.emit()

	if raw_string.begins_with("[ ] "):
		raw_string = raw_string.right(-4)
	elif raw_string.begins_with("[x] "):
		state = States.DONE
		raw_string = raw_string.right(-4)
	elif raw_string.begins_with("[-] "):
		state = States.FAILED
		raw_string = raw_string.right(-4)

	if raw_string.begins_with("> "):
		raw_string = raw_string.right(-2)
		is_folded =  true
	else:
		is_folded = false

	# trim any leading & trailing whitespace
	raw_string = raw_string.strip_edges()

	# Check if the text contains any tags (like a bookmark or a color tag) or
	# markup (like asterisks or underscores), and if so, trigger their effect
	# and then remove them from the text.
	while true:
		if raw_string.ends_with("[BOOKMARK]"):
			raw_string = raw_string.left(-10).strip_edges()
			is_bookmarked = true
			continue  # from the start of the while loop again

		var color_tag_reg_ex := RegEx.create_from_string(
			"\\[COLOR(?<digit>[1-5])\\]$"
		)
		var color_tag_reg_ex_match := color_tag_reg_ex.search(raw_string)
		if color_tag_reg_ex_match:
			raw_string = raw_string.left(-8).strip_edges()
			text_color_id = int(color_tag_reg_ex_match.get_string("digit"))
			continue  # from the start of the while loop again

		# NOTE: The following two if-conditions do *not* check if the matching
		# parts in the beginning and end of the raw text are distinct. This is
		# intended! It will also strip *any* number of asterisks or underscores
		# when the raw text only contains those and nothing else.

		if raw_string.begins_with("**") and raw_string.ends_with("**") or \
			raw_string.begins_with("__") and raw_string.ends_with("__"):
				raw_string = raw_string.left(-2).right(-2).strip_edges()
				is_bold = true
				continue  # from the start of the while loop again

		if raw_string.begins_with("*") and raw_string.ends_with("*") or \
			raw_string.begins_with("_") and raw_string.ends_with("_"):
				raw_string = raw_string.left(-1).right(-1).strip_edges()
				is_italic = true
				continue  # from the start of the while loop again

		break  # the while loop, nothing to replace was found anymore

	text = raw_string

	if text.is_empty():
		delete_requested.emit()
	else:
		sub_items = ToDoListData.new(indentation_level + 1)
		sub_items.changed.connect(changed.emit)


func as_string() -> String:
	var result := ""

	for i in indentation_level:
		result += "    "

	if self.state == States.DONE:
		result += "[x] "
	elif self.state == States.FAILED:
		result += "[-] "
	else:
		result += "[ ] "

	if is_folded:
		result += "> "

	if is_italic:
		result += "*"
	if is_bold:
		result += "**"
	result += text
	if is_bold:
		result += "**"
	if is_italic:
		result += "*"

	if is_bookmarked:
		result += " [BOOKMARK]"

	if text_color_id:
		result += " [COLOR%d]" % text_color_id

	for sub_item in sub_items.to_dos:
		result += "\n" + sub_item.as_string()

	return result
