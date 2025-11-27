extends RefCounted
class_name ToDoData


signal indent_requested
signal delete_requested
signal edit_requested

signal changed(reason: String)


enum States {
	TO_DO,
	DONE,
	FAILED
}


var state := States.TO_DO:
	set(value):
		if state != value:
			state = value
			changed.emit("'state' changed to '%s'" % States.keys()[value])

var text: String:
	set(value):
		if text != value:
			text = value
			changed.emit("'text' changed to '%s'" % Utils.shorten_string(
				value,
				30
			))

var is_bold := false:
	set(value):
		if is_bold != value:
			is_bold = value
			changed.emit("'is_bold' changed to '%s'" % value)

var is_italic := false:
	set(value):
		if is_italic != value:
			is_italic = value
			changed.emit("'is_italic' changed to '%s'" % value)

# NOTE: This is only left in for backwards compatibility. If any users used the
# old bookmark system, they can still grep their data to find the old bookmarks
# even though they're no longer accessible through Habituary itself.
# TODO: remove this later
var is_bookmarked := false:
	set(value):
		if is_bookmarked != value:
			is_bookmarked = value
			changed.emit("'is_bookmarked' changed to '%s'" % value)

var is_folded := false:
	set(value):
		if is_folded != value:
			is_folded = value
			changed.emit("'is_folded' changed to '%s'" % value)

var text_color_id: int:
	set(value):
		if text_color_id != value:
			text_color_id = value
			changed.emit("'text_color_id' changed to '%s'" % value)

var review_date: Date:
	set(value):
		if review_date != value:
			review_date = value
			if review_date == null:
				changed.emit("'review_date' changed to 'null'")
			else:
				changed.emit("'review_date' changed to '%s'" % value.as_string())

var sub_items := ToDoListData.new(self)

var indentation_level := 0:
	set(value):
		indentation_level = value
		sub_items.indentation_level = value + 1

var caret_position := 0  # Note: Does NOT persist across restarts!

var parent: ToDoListData


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

		var review_date_reg_ex := RegEx.create_from_string(
			"\\[REVIEW:(?<date>[0-9]{4}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01]))\\]"
		)
		var review_date_reg_ex_match := review_date_reg_ex.search(raw_string)
		if review_date_reg_ex_match:
			raw_string = raw_string.left(-19).strip_edges()
			review_date = Date.from_string(
				review_date_reg_ex_match.get_string("date")
			)
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

	if review_date:
		result += " [REVIEW:%s]" % review_date.as_string()

	for sub_item in sub_items.to_dos:
		if sub_item.text:
			result += "\n" + sub_item.as_string()

	return result


func duplicate() -> ToDoData:
	var copy := ToDoData.new()

	copy.state = state
	copy.text = text
	copy.is_bold = is_bold
	copy.is_italic = is_italic
	copy.is_bookmarked = is_bookmarked
	copy.is_folded = is_folded
	copy.text_color_id = text_color_id
	copy.indentation_level = indentation_level

	copy.sub_items = ToDoListData.new(copy)
	copy.sub_items.indentation_level = indentation_level + 1
	for to_do in sub_items.to_dos:
		copy.sub_items.add(to_do.duplicate())

	return copy


func edit(at_caret_position = null) -> void:
	if at_caret_position != null:
		caret_position = at_caret_position

	# find the file this to-do belongs to...
	var parent_file = parent
	while parent_file is not FileData:
		parent_file = parent_file.parent

	# ... and if it's not already visible...
	if not parent_file.keep_loaded:
		# ... auto-switch to the correct date
		Settings.current_day = Date.from_string(
			parent_file.name.trim_suffix(".txt")
		)

	edit_requested.emit()


func get_item_above() -> ToDoData:
	return parent.get_item_above(self)


func get_item_below() -> ToDoData:
	if not sub_items.is_empty():
		# item has at least one sub item -> return that
		return sub_items.to_dos[0]
	else:
		return parent.get_item_below(self)
