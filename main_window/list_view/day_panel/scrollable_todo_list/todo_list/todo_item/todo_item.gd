extends VBoxContainer

signal predecessor_requested
signal successor_requested

signal editing_started
signal list_save_requested(reason)

signal folded
signal unfolded

signal moved_up
signal moved_down

@onready var last_index := get_index()

# used to avoid emitting `list_save_requested` too early
var _initialization_finished := false

var date : Date:
	get():
		# FIXME: avoid using a relative path that involves parent nodes
		if "date" in get_node("../../../../../../.."):
			return Date.new(get_node("../../../../../../..").date.as_dict())
		else:
			return null

@export var text := "":
	set(value):
		if text != value:
			text = value
			if is_inside_tree():
				%Edit.text = text

				if date:
					EventBus.bookmark_changed.emit(self, date, get_index())

				if _initialization_finished:
					list_save_requested.emit("text changed")

enum States { TO_DO, DONE, FAILED }
@export var state := States.TO_DO:
	set(value):
		state = value
		if is_inside_tree():
			if state == States.TO_DO:
				%CheckBox.icon = preload(
					"images/to_do.svg"
				)
			elif state == States.DONE:
				%CheckBox.icon = preload(
					"images/done.svg"
				)
			elif state == States.FAILED:
				%CheckBox.icon = preload(
					"images/failed.svg"
				)

			%CheckBox.button_pressed = (state != States.TO_DO)

			if not _contains_mouse_cursor:
				if self.state == States.DONE:
					%CheckBox.theme_type_variation = "ToDoItem_Done"
				elif self.state == States.FAILED:
					%CheckBox.theme_type_variation = "ToDoItem_Failed"
				else:
					%CheckBox.theme_type_variation = "ToDoItem"

			_apply_state_relative_formating.call_deferred()

			if date:
				EventBus.bookmark_changed.emit(self, date, get_index())

			if _initialization_finished and self.text:
				list_save_requested.emit("state changed")

@export var is_heading := false:
	set(value):
		is_heading = value
		if is_inside_tree():
			if is_heading:
				$MainRow.theme_type_variation = "ToDoItem_Heading"
				%Heading.get_node("Tooltip").text = "Undo Heading"
				%Delete.text = "Delete Heading"
				%FoldHeading.show()
				%CheckBox.hide()
			else:
				if is_folded:
					is_folded = false
				$MainRow.theme_type_variation = "ToDoItem_NoHeading"
				%Heading.get_node("Tooltip").text = "Make Heading"
				%Delete.text = "Delete To-Do"
				%FoldHeading.hide()
				%CheckBox.show()
			%Delete.get_node("Tooltip").text = %Delete.text
			_on_editing_options_resized()
			%Heading.button_pressed = is_heading

			if _initialization_finished and self.text:
				list_save_requested.emit("is_heading changed")

@export var is_bold := false:
	set(value):
		is_bold = value
		if is_inside_tree():
			if is_bold:
				%Bold.get_node("Tooltip").text = "Undo Bold"
			else:
				%Bold.get_node("Tooltip").text = "Make Bold"
			_apply_formatting()
			%Bold.button_pressed = is_bold

			if _initialization_finished and self.text:
				list_save_requested.emit("is_bold changed")

@export var is_italic := false:
	set(value):
		is_italic = value
		if is_inside_tree():
			if is_italic:
				%Italic.get_node("Tooltip").text = "Undo Italic"
			else:
				%Italic.get_node("Tooltip").text = "Make Italic"
			_apply_formatting()
			%Italic.button_pressed = is_italic

			if _initialization_finished and self.text:
				list_save_requested.emit("is_italic changed")

var _contains_mouse_cursor := false

var is_folded := false:
	set(value):
		is_folded = value

		if not is_node_ready():
			await self.ready

		%FoldHeading.button_pressed = is_folded

		if is_folded:
			self.folded.emit.call_deferred()
			%ExtraInfo.show()
		else:
			self.unfolded.emit.call_deferred()
			%ExtraInfo.hide()

		if _initialization_finished and self.text:
			list_save_requested.emit("is_folded changed")


var is_bookmarked := false:
	set(value):
		is_bookmarked = value

		if is_inside_tree():
			if is_bookmarked:
				%Bookmark.text = %Bookmark.text.replace("Add", "Remove")
				%BookmarkIndicator.show()
			else:
				%Bookmark.text = %Bookmark.text.replace("Remove", "Add")
				%BookmarkIndicator.hide()
			%Bookmark.get_node("Tooltip").text = %Bookmark.text
			%Bookmark.button_pressed = is_bookmarked

			if _initialization_finished and self.text:
				list_save_requested.emit("is_bookmarked changed")

var indentation_level := 0:
	set(value):
		var old_indentation_level := indentation_level
		indentation_level = clamp(value, 0, get_maximum_indentation_level())
		var change := indentation_level - old_indentation_level

		%Indentation.custom_minimum_size.x = indentation_level * 20
		$Triangle.custom_minimum_size.x = 22 + indentation_level * 40

		if self.text: # skip this step for newly created to-dos that haven't been saved yet
			if is_inside_tree() and change:
				_reindent_sub_todos(change, old_indentation_level)

			if _initialization_finished:
				list_save_requested.emit("indentation_level changed")


var text_color_id := 0:
	set(value):
		var old_value = text_color_id
		text_color_id = wrapi(value, 0, Settings.to_do_text_colors.size() + 1)

		if text_color_id:
			var color = Settings.to_do_text_colors[text_color_id - 1]
			%TextColor.get("theme_override_styles/panel").bg_color = color
			%TextColor.get("theme_override_styles/panel").draw_center = true
			%Edit.add_theme_color_override("font_placeholder_color", Color(color, 0.7))
			%Edit.add_theme_color_override("font_color", color)
		else:
			%TextColor.get("theme_override_styles/panel").draw_center = false
			%Edit.remove_theme_color_override("font_placeholder_color")
			%Edit.remove_theme_color_override("font_color")

		if old_value != value:
			if _initialization_finished and self.text:
				list_save_requested.emit("text_color_id changed")

var _editing_options_shrink_threshold : int

var hide_tween: Tween


func _ready() -> void:
	# Briefly switch to the longer version of the button label:
	%Bookmark.text = %Bookmark.text.replace("Add", "Remove")
	# Measure the minimum size of the editing options (i.e. *with* labels), this will serve as the
	# threshold width value at which all labels in the editing options will be hidden:
	_editing_options_shrink_threshold = %EditingOptions.get_combined_minimum_size().x
	# Then switch back to the original button label again:
	%Bookmark.text = %Bookmark.text.replace("Remove", "Add")

	_set_initial_state()
	_connect_signals()

	$Triangle.hide()
	%EditingOptions.hide()
	%BookmarkIndicator.hide()
	%DragHandle.visible = false

	set_deferred("_initialization_finished", true) # deferred, in case this item is loaded from disk

	await get_tree().process_frame # i.e. until _initialization_finished == true

	if not self.text: # i.e. it's a newly created to-do (not restored from disk)
		var index = self.get_index()
		if index > 0:
			var todo_list := self.get_parent()
			var predecessor = todo_list.get_child(index - 1)
			var successor
			if index < todo_list.get_child_count() - 1:
				successor = todo_list.get_child(index + 1)
			if predecessor.text.ends_with(":") or (successor and \
				successor.indentation_level == predecessor.indentation_level + 1):
					self.indentation_level = predecessor.indentation_level + 1
			else:
				self.indentation_level = predecessor.indentation_level

	Settings.fade_ticked_off_todos_changed.connect(_apply_state_relative_formating)


func _set_initial_state() -> void:
	# FIXME: temporary band-aid fix until it's possible to bookmark to-dos in the capture panel, too
	if not date:
		%Bookmark.hide()
		%Delete.size_flags_horizontal += SIZE_EXPAND


func _connect_signals() -> void:
	#region Global Signals
	Settings.search_query_changed.connect(_check_for_search_query_match)
	_check_for_search_query_match.call_deferred() # deferred, in case this item is loaded from disk

	Settings.hide_ticked_off_todos_changed.connect(_apply_state_relative_formating)

	EventBus.bookmark_jump_requested.connect(func(bookmarked_date, bookmarked_line_number):
		if date:
			if self.is_bookmarked and date.day_difference_to(bookmarked_date) == 0 \
				and get_index() == bookmarked_line_number:
					edit()
	)

	Settings.to_do_text_colors_changed.connect(func():
		if text_color_id:
			var color = Settings.to_do_text_colors[text_color_id - 1]
			%TextColor.get("theme_override_styles/panel").bg_color = color
			%TextColor.get("theme_override_styles/panel").draw_center = true
			%Edit.add_theme_color_override("font_placeholder_color", Color(color, 0.7))
			%Edit.add_theme_color_override("font_color", color)
	)
	#endregion

	#region Local Signals
	focus_exited.connect(_on_focus_exited)
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	tree_exiting.connect(_on_tree_exiting)

	%CheckBox.gui_input.connect(_on_check_box_gui_input)

	%FoldHeading.toggled.connect(_on_fold_heading_toggled)

	%Content.gui_input.connect(_on_gui_input)

	%Edit.text_changed.connect(_on_edit_text_changed)
	%Edit.text_submitted.connect(_on_edit_text_submitted)
	%Edit.focus_entered.connect(edit)
	%Edit.focus_exited.connect(_on_edit_focus_exited)
	%Edit.gui_input.connect(_on_edit_gui_input)
	%Edit.resized.connect(_on_edit_resized)

	%BookmarkIndicator.gui_input.connect(_on_bookmark_indicator_gui_input)

	%EditingOptions.resized.connect(_on_editing_options_resized)
	_on_editing_options_resized()

	%Heading.toggled.connect(_on_heading_toggled)

	%Bold.toggled.connect(_on_bold_toggled)

	%Italic.toggled.connect(_on_italic_toggled)

	%TextColor.gui_input.connect(_on_text_color_gui_input)

	%Bookmark.pressed.connect(_on_bookmark_pressed)

	%Delete.pressed.connect(delete)
	#endregion


func is_in_edit_mode() -> bool:
	return %EditingOptions.visible


func edit() -> void:
	%Edit.grab_focus()
	$Triangle.show()
	%EditingOptions.show()

	#region Make sure edited to-do is visible
	# FIXME: this is pretty hacky patch...
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll_container := get_node("../../../..")
	scroll_container.ensure_control_visible(self)
	var row_height = scroll_container.TODO_ITEM_HEIGHT
	if scroll_container.scroll_vertical % row_height != 0:
		# round to next multiple of `row_height`
		scroll_container.scroll_vertical += (
			row_height - scroll_container.scroll_vertical % row_height
		)
	#endregion

	editing_started.emit()


func delete() -> void:
	if is_bookmarked:
		EventBus.bookmark_removed.emit(self)
	self.unfolded.emit()

	_reindent_sub_todos(-1)

	if %Edit.text:
		var to_do_list := get_parent()
		var items_in_list := to_do_list.get_child_count()
		if items_in_list > 1:
			var position_in_list := self.get_index()
			if items_in_list == position_in_list + 1:
				# The deleted item is the last in the list: select its predecessor!
				to_do_list.get_child(position_in_list - 1).edit()
			else:
				# The deleted item is *not* the last in the list: select its successor!
				to_do_list.get_child(position_in_list + 1).edit()

	queue_free()
	if self.text:
		await tree_exited
		list_save_requested.emit("to-do deleted")


func _reindent_sub_todos(change : int, threshold := indentation_level) -> void:
	if change == 0 or threshold < 0:
		return

	var sub_todos := []

	var SUCCESSOR_IDS := range(get_index() + 1, get_parent().get_child_count())
	for successor_id in SUCCESSOR_IDS:
		var successor = get_parent().get_child(successor_id)
		if successor.indentation_level == threshold + 1:
			sub_todos.append(successor)
		elif successor.indentation_level <= threshold:
			break # end of scope reached

	for sub_todo in sub_todos:
		sub_todo.indentation_level += change


func _on_edit_resized() -> void:
	var font : Font = %Edit.get_theme_font("font")
	var font_size : int = %Edit.get_theme_font_size("font")

	const SHORT_PLACEHOLDER := "Enter To-Do"
	var short_placeholder_width := font.get_string_size(
		SHORT_PLACEHOLDER,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
	).x

	const LONG_PLACEHOLDER := SHORT_PLACEHOLDER + " (or Press ESC to Cancel)"
	var long_placeholder_width := font.get_string_size(
		LONG_PLACEHOLDER,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
	).x

	var available_width : int = %Edit.size.x
	if available_width >= long_placeholder_width:
		%Edit.placeholder_text = LONG_PLACEHOLDER
	elif available_width >= short_placeholder_width:
		%Edit.placeholder_text = SHORT_PLACEHOLDER
	else:
		%Edit.placeholder_text = ""


func _on_edit_text_changed(new_text: String) -> void:
	if new_text.begins_with("- ") and \
		self.indentation_level < get_maximum_indentation_level():
			self.indentation_level += 1
			%Edit.text = new_text.right(-2).strip_edges()
	else:
		if date:
			EventBus.bookmark_changed.emit(self, date, get_index())
		_check_for_search_query_match()


func _on_edit_text_submitted(new_text: String, key_input := true) -> void:
	# trim any leading & trailing whitespace
	new_text = new_text.strip_edges()

	# if users manually added the bookmark tag to the end of the to-do's text, remove it...
	while new_text.ends_with("[BOOKMARK]"):
		new_text = new_text.left(-10).strip_edges()
	# ... and change the line edit's text accordingly
	%Edit.text = new_text
	_on_edit_text_changed(new_text)

	var new_item := (self.text == "")

	if new_text:
		if not key_input:
			self.text = new_text
		%Edit.release_focus()
		%EditingOptions.hide()
		$Triangle.hide()
		%DragHandle.visible = _contains_mouse_cursor

		%Edit.caret_column = 0   # scroll item text back to its beginning

		if new_item and key_input:
			if Input.is_key_pressed(KEY_SHIFT):
				predecessor_requested.emit()
			else:
				successor_requested.emit()
	else:
		delete()


func _on_edit_focus_exited() -> void:
	if not is_queued_for_deletion() and %Edit.visible:
		await get_tree().process_frame
		if is_inside_tree():
			var focus_owner := get_viewport().gui_get_focus_owner()
			if not focus_owner or (not focus_owner == self and not focus_owner.owner == self):
				_on_edit_text_submitted(%Edit.text, false)


func _on_focus_exited() -> void:
	_on_edit_focus_exited()


func _on_content_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if not is_in_edit_mode():
			accept_event()
			if self.state == States.TO_DO and _contains_mouse_cursor:
				edit()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return get_node("../../..")._can_drop_data(_at_position, data)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# FIXME: avoid asumptions about the parent's of this node
	get_node("../../..")._drop_data(position - Vector2.ONE, data)


func save_to_disk(file : FileAccess) -> void:
	if not self.text:
		return

	var string := ""

	if self.indentation_level > 0:
		for i in self.indentation_level:
			string += "  "

	if is_heading:
		if is_folded:
			string += "> "
		else:
			string += "v "
	elif self.state == States.DONE:
		string += "[x] "
	elif self.state == States.FAILED:
		string += "[-] "
	else:
		string += "[ ] "

	if is_italic:
		string += "*"
	if is_bold:
		string += "**"
	string += self.text
	if is_bold:
		string += "**"
	if is_italic:
		string += "*"

	if is_bookmarked:
		string += " [BOOKMARK]"

	if text_color_id:
		string += " [COLOR%d]" % text_color_id

	file.store_line(string)


func load_from_disk(line : String) -> void:
	while line.begins_with("  "):
		line = line.right(-2)
		self.indentation_level += 1

	if line.begins_with("# ") or line.begins_with("v "):
		line = line.right(-2)
		self.is_heading = true
		self.is_folded = false
	elif line.begins_with("> "):
		line = line.right(-2)
		self.is_heading = true
		self.is_folded = true
	elif line.begins_with("[ ] "):
		line = line.right(-4)
	elif line.begins_with("[x] "):
		self.state = States.DONE
		line = line.right(-4)
	elif line.begins_with("[-] "):
		self.state = States.FAILED
		line = line.right(-4)
	else:
		push_warning("Unknown format for line \"%s\" (will be automatically converted into a todo)" % line)

	var reg_ex := RegEx.new()
	reg_ex.compile(" \\[COLOR(?<digit>[1-5])\\]$")
	var reg_ex_match := reg_ex.search(line)
	if reg_ex_match:
		line = line.substr(0, line.length() - 9)
		text_color_id = int(reg_ex_match.get_string("digit"))

	if line.ends_with(" [BOOKMARK]"):
		line = line.substr(0, line.length() - 11)
		is_bookmarked = true

	if line.begins_with("**") and  line.ends_with("**"):
		line = line.substr(2, line.length() - 4)
		is_bold = true
	if line.begins_with("*") and  line.ends_with("*"):
		line = line.substr(1, line.length() - 2)
		is_italic = true

	self.text = line


func _on_mouse_entered() -> void:
	_contains_mouse_cursor = true
	%CheckBox.theme_type_variation = "ToDoItem_Focused"
	%FoldHeading.theme_type_variation = "ToDoItem_Focused"
	if not get_viewport().gui_is_dragging():
		%DragHandle.show()


func _on_mouse_exited() -> void:
	_contains_mouse_cursor = false
	if not is_queued_for_deletion():
		if not is_in_edit_mode():
			%DragHandle.hide()

		if self.state == States.DONE:
			%CheckBox.theme_type_variation = "ToDoItem_Done"
		elif self.state == States.FAILED:
			%CheckBox.theme_type_variation = "ToDoItem_Failed"
		else:
			%CheckBox.theme_type_variation = "ToDoItem"

		%FoldHeading.theme_type_variation = "ToDoItem"


func _on_fold_heading_toggled(toggled_on: bool) -> void:
	self.is_folded = toggled_on


func set_extra_info(num_done : int , num_items : int) -> void:
	%ExtraInfo.text = "%d/%d" % [num_done, num_items]


func _input(event: InputEvent) -> void:
	if is_in_edit_mode():
		if event.is_action_pressed("toggle_todo", false, true):
			self.state = States.DONE if self.state != States.DONE else States.TO_DO
		elif event.is_action_pressed("cancel_todo", false, true):
			self.state = States.FAILED if self.state != States.FAILED else States.TO_DO
		elif event.is_action_pressed("previous_todo", true, true):
			var index := get_index()
			if index:
				get_parent().get_child(index - 1).edit()
		elif event.is_action_pressed("next_todo", true, true):
			var index := get_index()
			if index < get_parent().get_child_count() - 1:
				get_parent().get_child(index + 1).edit()
		elif event.is_action_pressed("move_todo_up", true, true):
			moved_up.emit()
		elif event.is_action_pressed("move_todo_down", true, true):
			moved_down.emit()
		elif event.is_action_pressed("indent_todo", false, true):
			self.indentation_level += 1
		elif event.is_action_pressed("unindent_todo", false, true):
			if self.text: # skip this step for newly created to-dos that haven't been saved yet
				# Move the to-do & all its sub items to the end of its current scope. This matters
				# if it has siblings, which would become sub items after deindentation otherwise!
				# FIXME: That is a rather hacky way to achieve this...
				self.get_node("../../..").move_to_do(self, 999_999_999)
			self.indentation_level -= 1
		elif event.is_action_pressed("next_text_color", false, true):
			text_color_id += 1
		elif event.is_action_pressed("previous_text_color", false, true):
			text_color_id -= 1
		else:
			return # early, i.e. ignore the input

		accept_event()


func _on_check_box_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.ctrl_pressed:
					_add_end_time()
				self.state = States.DONE if self.state != States.DONE else States.TO_DO
			MOUSE_BUTTON_RIGHT:
				if event.ctrl_pressed:
					_add_start_time()
				else:
					self.state = States.FAILED if self.state != States.FAILED else States.TO_DO


func _add_start_time() -> void:
	var regex1 = RegEx.new()
	regex1.compile("^[0-9]{2}:[0-9]{2}: ")
	var regex2 = RegEx.new()
	regex2.compile("^[0-9]{2}:[0-9]{2}–[0-9]{2}:[0-9]{2}: ")
	if regex1.search(%Edit.text):
		pass # do nothing
	elif regex2.search(%Edit.text):
		pass # do nothing
	else:
		# add first time
		var current_time := Time.get_time_string_from_system().left(5)
		%Edit.text = current_time + ": " + %Edit.text


func _add_end_time() -> void:
	var regex1 = RegEx.new()
	regex1.compile("^[0-9]{2}:[0-9]{2}: ")
	var result1 = regex1.search(%Edit.text)
	var regex2 = RegEx.new()
	regex2.compile("^[0-9]{2}:[0-9]{2}–[0-9]{2}:[0-9]{2}: ")
	if result1:
		var current_time := Time.get_time_string_from_system().left(5)
		if result1.get_string(0).left(-2) == current_time:
			# replace first time
			%Edit.text = current_time + %Edit.text.right(-5)
		else:
			# keep first time, add second time
			%Edit.text = %Edit.text.left(5) + "–" + current_time + %Edit.text.right(-5)
	elif regex2.search(%Edit.text):
		var current_time := Time.get_time_string_from_system().left(5)
		# keep first time, replace second time
		%Edit.text = %Edit.text.left(5) + "–" + current_time + %Edit.text.right(-11)
	else:
		# add first time
		var current_time := Time.get_time_string_from_system().left(5)
		%Edit.text = current_time + ": " + %Edit.text


func _apply_formatting() -> void:
	var font : Font

	if is_bold:
		if is_italic:
			font = preload("res://theme/fonts/OpenSans-ExtraBoldItalic.ttf")
		else:
			font = preload("res://theme/fonts/OpenSans-ExtraBold.ttf")
	else:
		if is_italic:
			font = preload("res://theme/fonts/OpenSans-MediumItalic.ttf")
		else:
			font = preload("res://theme/fonts/OpenSans-Medium.ttf")

	%Edit.add_theme_font_override("font", font)
	%ExtraInfo.add_theme_font_override("font", font)


func _on_heading_toggled(toggled_on: bool) -> void:
	is_heading = toggled_on


func _on_bold_toggled(toggled_on: bool) -> void:
	is_bold = toggled_on


func _on_italic_toggled(toggled_on: bool) -> void:
	is_italic = toggled_on


func _on_editing_options_resized() -> void:
	if %EditingOptions.size.x <= _editing_options_shrink_threshold:
		%FormatLabel.hide()

		%Delete.clip_text = true
		%Delete.get_node("Tooltip").hide_text = false

		%Bookmark.clip_text = true
		%Bookmark.get_node("Tooltip").hide_text = false
	else:
		%FormatLabel.show()

		%Delete.clip_text = false
		%Delete.get_node("Tooltip").hide_text = true

		%Bookmark.clip_text = false
		%Bookmark.get_node("Tooltip").hide_text = true


func _check_for_search_query_match() -> void:
	if not Settings.search_query:
		text_color_id = text_color_id
		%Edit.theme_type_variation = "LineEdit_Minimal"
		%Edit.modulate.a = 1.0
	elif %Edit.text.contains(Settings.search_query):
		%Edit.theme_type_variation = "LineEdit_SearchMatch"
		%Edit.modulate.a = 1.0
	else:
		%Edit.theme_type_variation = "LineEdit_Minimal"
		%Edit.modulate.a = 0.1


func _on_bookmark_pressed() -> void:
	is_bookmarked = not is_bookmarked

	if is_bookmarked:
		EventBus.bookmark_added.emit(self)
	else:
		EventBus.bookmark_removed.emit(self)


func _on_bookmark_indicator_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		%BookmarkIndicator/Tooltip.hide_tooltip()
		edit()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		release_focus()


func _on_text_color_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT, MOUSE_BUTTON_WHEEL_UP:
				text_color_id += 1
			MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_WHEEL_DOWN:
				text_color_id -= 1
			_:
				return # early, i.e. ignore the input

		get_viewport().set_input_as_handled()
		%TextColor/Tooltip.hide_tooltip()


# NOTE: `tree_exiting` will be emitted both when this panel is about to be removed from the tree
# because the user scrolled the list' view, as well as on a NOTIFICATION_WM_CLOSE_REQUEST, but also
# when an item is deleted (which is why we check if it's queded for deletion first).
func _on_tree_exiting() -> void:
	if not is_queued_for_deletion():
		# submit any yet unsubmitted changes
		if %Edit.text != self.text:
			self.text = %Edit.text


func _apply_state_relative_formating() -> void:
	if Settings.hide_ticked_off_todos:
		if state != States.TO_DO:
			if not _has_unticked_sub_todos():
				if hide_tween:
					hide_tween.kill()
				modulate.a = 1.0
				hide_tween = create_tween()
				hide_tween.tween_property(self, "modulate:a", 0.0, 1.5)
				await hide_tween.finished
				self.hide()

				var parent_todo := get_parent_todo()
				if parent_todo and parent_todo.state != States.TO_DO:
					parent_todo._apply_state_relative_formating()
		else:
			if hide_tween:
				hide_tween.kill()
				modulate.a = 1.0
	else:
		if hide_tween:
			hide_tween.kill()
		modulate.a = 1.0
		self.show()

		if Settings.fade_ticked_off_todos:
			if state != States.TO_DO:
				%CheckBox.modulate.a = 0.5
				%Content.modulate.a = 0.5
			else:
				%CheckBox.modulate.a = 1.0
				%Content.modulate.a = 1.0
		else:
			%CheckBox.modulate.a = 1.0
			%Content.modulate.a = 1.0


func get_maximum_indentation_level() -> int:
	var max_indentation_level := 3

	if self.get_index() > 0:
		# The maximum indentation level of a to-do is equal to the indentation
		# level of its predecessor plus one, unless that value would be higher
		# than the overall allowed maximum specified above.
		var predecessor := self.get_parent().get_child(self.get_index() - 1)
		max_indentation_level = min(
			predecessor.indentation_level + 1,
			max_indentation_level
		)
	else:
		# The first item in a list is not allowed to be indented!
		max_indentation_level = 0

	return max_indentation_level


func _on_edit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"):
		if %Edit.text == "" and self.indentation_level > 0:
			self.indentation_level -= 1


func _has_unticked_sub_todos() -> bool:
	var SUCCESSOR_IDS := range(get_index() + 1, get_parent().get_child_count())
	for successor_id in SUCCESSOR_IDS:
		var successor = get_parent().get_child(successor_id)
		if successor.indentation_level <= indentation_level:
			break # end of scope reached
		if successor.state == States.TO_DO:
			return true

	return false


func get_parent_todo() -> Control:
	if indentation_level:
		var PREDECESSOR_IDS := range(get_index() - 1, 0, -1)
		for predecessor_id in PREDECESSOR_IDS:
			var predecessor = get_parent().get_child(predecessor_id)
			if predecessor.indentation_level < indentation_level:
				return predecessor

	return null
