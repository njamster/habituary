class_name ToDoItem
extends VBoxContainer


@onready var last_index := get_index()


# used to avoid emitting `list_save_requested` too early
var _initialization_finished := false

var date : Date:
	get():
		var day_panel := get_day_panel()
		if day_panel:
			return Date.new(day_panel.date.as_dict())
		else:
			return null

var text := "":
	set(value):
		if text != value:
			text = value
			if is_inside_tree():
				%Edit.text = text

				if date:
					EventBus.bookmark_changed.emit(self, date, get_index())

				if _initialization_finished:
					get_to_do_list()._start_debounce_timer("text changed")

enum States { TO_DO, DONE, FAILED }
var state := States.TO_DO:
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

			if _initialization_finished:
				_apply_state_relative_formatting()

			if date:
				EventBus.bookmark_changed.emit(self, date, get_index())

			if _initialization_finished and self.text:
				get_to_do_list()._start_debounce_timer("state changed")

var is_heading := false:
	set(value):
		is_heading = value
		if is_inside_tree():
			if is_heading:
				%MainRow.theme_type_variation = "ToDoItem_Heading"
			else:
				%MainRow.theme_type_variation = "ToDoItem_NoHeading"

			if has_node("EditingOptions"):
				$EditingOptions.update_heading()

			if _initialization_finished and self.text:
				get_to_do_list()._start_debounce_timer("is_heading changed")

var is_bold := false:
	set(value):
		is_bold = value
		if is_inside_tree():
			_apply_formatting()

			if has_node("EditingOptions"):
				$EditingOptions.update_bold()

			if _initialization_finished and self.text:
				get_to_do_list()._start_debounce_timer("is_bold changed")

var is_italic := false:
	set(value):
		is_italic = value
		if is_inside_tree():
			_apply_formatting()

			if has_node("EditingOptions"):
				$EditingOptions.update_italic()

			if _initialization_finished and self.text:
				get_to_do_list()._start_debounce_timer("is_italic changed")

var _contains_mouse_cursor := false

var is_folded := false:
	set(value):
		is_folded = value

		%FoldHeading.button_pressed = value

		if is_folded:
			%SubItems.hide()
		else:
			%SubItems.show()

		if _initialization_finished and self.text:
			get_to_do_list()._start_debounce_timer("is_folded changed")


var is_bookmarked := false:
	set(value):
		is_bookmarked = value

		if is_inside_tree():
			if is_bookmarked:
				%BookmarkIndicator.show()
			else:
				%BookmarkIndicator.hide()

			if has_node("EditingOptions"):
				$EditingOptions.update_bookmark()

			if _initialization_finished and self.text:
				get_to_do_list()._start_debounce_timer("is_bookmarked changed")

var indentation_level := 0:
	set(value):
		indentation_level = clamp(value, 0, get_maximum_indentation_level())


var text_color_id := 0:
	set(value):
		var old_value = text_color_id
		text_color_id = wrapi(value, 0, Settings.to_do_text_colors.size() + 1)

		if text_color_id:
			var color = Settings.to_do_text_colors[text_color_id - 1]
			%Edit.add_theme_color_override("font_placeholder_color", Color(color, 0.7))
			%Edit.add_theme_color_override("font_color", color)
		else:
			%Edit.remove_theme_color_override("font_placeholder_color")
			%Edit.remove_theme_color_override("font_color")

		if has_node("EditingOptions"):
			$EditingOptions.update_text_color()

		if old_value != value:
			if _initialization_finished and self.text:
				get_to_do_list()._start_debounce_timer("text_color_id changed")

var hide_tween: Tween


func _ready() -> void:
	_set_initial_state()
	_connect_signals()

	%BookmarkIndicator.hide()
	%DragHandle.visible = false

	# deferred for two frames, in case this item is loaded from disk
	await get_tree().process_frame
	await get_tree().process_frame
	_initialization_finished = true

	if not self.text: # i.e. it's a newly created to-do (not restored from disk)
		var index = self.get_index()
		if index > 0:
			var item_list := get_item_list()
			var predecessor = item_list.get_child(index - 1)
			var successor
			if index < item_list.get_child_count() - 1:
				successor = item_list.get_child(index + 1)
			if predecessor.text.ends_with(":") or (successor and \
				successor.indentation_level == predecessor.indentation_level + 1):
					self.indentation_level = predecessor.indentation_level + 1
			else:
				self.indentation_level = predecessor.indentation_level

	Settings.fade_ticked_off_todos_changed.connect(_apply_state_relative_formatting)


func _set_initial_state() -> void:
	%CheckBox.show()
	%FoldHeading.hide()
	%ExtraInfo.hide()

	_on_fold_heading_toggled(self.is_folded)

	_apply_state_relative_formatting.call_deferred(true)


func _connect_signals() -> void:
	#region Global Signals
	Settings.search_query_changed.connect(_check_for_search_query_match)
	_check_for_search_query_match.call_deferred() # deferred, in case this item is loaded from disk

	Settings.hide_ticked_off_todos_changed.connect(
		_apply_state_relative_formatting.bind(true)
	)

	EventBus.bookmark_jump_requested.connect(func(bookmarked_date, bookmarked_line_number):
		if date:
			if self.is_bookmarked and date.day_difference_to(bookmarked_date) == 0 \
				and get_index() == bookmarked_line_number:
					edit()
	)

	Settings.to_do_text_colors_changed.connect(func():
		if text_color_id:
			var color = Settings.to_do_text_colors[text_color_id - 1]
			%Edit.add_theme_color_override("font_placeholder_color", Color(color, 0.7))
			%Edit.add_theme_color_override("font_color", color)
	)
	#endregion

	#region Local Signals
	focus_exited.connect(_on_focus_exited)
	gui_input.connect(_on_gui_input)
	tree_exiting.connect(_on_tree_exiting)

	%MainRow.mouse_entered.connect(_on_mouse_entered)
	%MainRow.mouse_exited.connect(_on_mouse_exited)

	%CheckBox.gui_input.connect(_on_check_box_gui_input)

	%FoldHeading.toggled.connect(_on_fold_heading_toggled)

	%Edit.gui_input.connect(_on_gui_input)

	%Edit.text_changed.connect(_on_edit_text_changed)
	%Edit.text_submitted.connect(_on_edit_text_submitted)
	%Edit.focus_entered.connect(_on_edit_focus_entered)
	%Edit.focus_exited.connect(_on_edit_focus_exited)
	%Edit.gui_input.connect(_on_edit_gui_input)
	%Edit.resized.connect(_on_edit_resized)

	%BookmarkIndicator.gui_input.connect(_on_bookmark_indicator_gui_input)

	%SubItems.child_entered_tree.connect(_on_sub_item_added.unbind(1))
	%SubItems.child_exiting_tree.connect(
		_on_sub_item_removed.unbind(1),
		CONNECT_DEFERRED
	)
	#endregion


func is_in_edit_mode() -> bool:
	return has_node("EditingOptions")


func edit() -> void:
	%Edit.grab_focus()
	%Edit.edit()

	if has_meta("caret_position"):
		%Edit.caret_column = get_meta("caret_position")


func _on_edit_focus_entered() -> void:
	if not is_in_edit_mode():
		var editing_options := \
			preload("editing_options/editing_options.tscn").instantiate()
		add_child(editing_options, true)
		# place the editing options above the SubItems container
		move_child(editing_options, $Indentation.get_index())

	#region Make sure edited to-do is visible
	# FIXME: this is pretty hacky patch...
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll_container := get_to_do_list().get_scroll_container()
	scroll_container.ensure_control_visible(self)
	var row_height = scroll_container.TODO_ITEM_HEIGHT
	if scroll_container.scroll_vertical % row_height != 0:
		# round to next multiple of `row_height`
		scroll_container.scroll_vertical += (
			row_height - scroll_container.scroll_vertical % row_height
		)
	#endregion

	get_to_do_list().hide_line_highlight()


func delete() -> void:
	for i in range(%SubItems.get_child_count() - 1, -1, -1):
		%SubItems.unindent_todo(%SubItems.get_child(i))

	if is_bookmarked:
		EventBus.bookmark_removed.emit(self)

	_reindent_sub_todos(-1)

	if %Edit.text:
		var successor = get_item_list().get_successor_todo(self)
		if successor:
			successor.edit()
		else:
			var predecessor = get_item_list().get_predecessor_todo(self)
			if predecessor:
				predecessor.edit()
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	queue_free()
	if self.text:
		await tree_exited
		get_to_do_list()._start_debounce_timer("to-do deleted")


func _reindent_sub_todos(change : int, threshold := indentation_level) -> void:
	if change == 0 or threshold < 0:
		return

	var sub_todos := []

	var SUCCESSOR_IDS := range(get_index() + 1, get_item_list().get_child_count())
	for successor_id in SUCCESSOR_IDS:
		var successor = get_item_list().get_child(successor_id)
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
	# hide the mouse cursor once the user starts typing
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	if new_text.begins_with("- ") and \
		self.indentation_level < get_maximum_indentation_level():
			self.indentation_level += 1
			%Edit.text = new_text.right(-2).strip_edges()
	else:
		if date:
			EventBus.bookmark_changed.emit(self, date, get_index())
		_check_for_search_query_match()


func _strip_text(raw_text: String) -> String:
	# trim any leading & trailing whitespace
	raw_text = raw_text.strip_edges()

	# if users manually added the bookmark tag to the end of the to-do's text, remove it...
	while raw_text.ends_with("[BOOKMARK]"):
		raw_text = raw_text.left(-10).strip_edges()

	return raw_text


func _on_edit_text_submitted(new_text: String, key_input := true) -> void:
	# save caret_column value, as it will be reset once %Edit.text is set
	set_meta("caret_position", %Edit.caret_column)

	new_text = _strip_text(new_text)
	%Edit.text = new_text
	_on_edit_text_changed(new_text)

	var new_item := (self.text == "")

	if new_text:
		self.text = new_text
		%Edit.release_focus()
		%DragHandle.visible = _contains_mouse_cursor

		%Edit.caret_column = 0   # scroll item text back to its beginning

		if new_item:
			if key_input:
				if Input.is_key_pressed(KEY_SHIFT):
					get_item_list().add_todo_above(self)
				else:
					get_item_list().add_todo_below(self)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		delete()


func _on_edit_focus_exited() -> void:
	await get_tree().process_frame
	if is_inside_tree() and not is_queued_for_deletion() and is_in_edit_mode():
		var focus_owner := get_viewport().gui_get_focus_owner()
		if not focus_owner or (not focus_owner == self and not focus_owner.owner == self):
			_on_edit_text_submitted(%Edit.text, false)
			if has_node("EditingOptions"):
				$EditingOptions.queue_free()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_focus_exited() -> void:
	_on_edit_focus_exited()


func _on_content_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if not is_in_edit_mode():
			accept_event()
			if self.state == States.TO_DO and _contains_mouse_cursor:
				edit()


func save_to_disk(file: FileAccess, depth := 0) -> void:
	if not self.text:
		return

	var stripped_text = _strip_text(self.text)
	if not stripped_text:
		return

	var string := ""

	for i in depth:
		string += "    "

	if self.state == States.DONE:
		string += "[x] "
	elif self.state == States.FAILED:
		string += "[-] "
	else:
		string += "[ ] "

	if is_folded:
		string += "> "

	if is_italic:
		string += "*"
	if is_bold:
		string += "**"
	string += stripped_text
	if is_bold:
		string += "**"
	if is_italic:
		string += "*"

	if is_bookmarked:
		string += " [BOOKMARK]"

	if text_color_id:
		string += " [COLOR%d]" % text_color_id

	file.store_line(string)

	for sub_item in %SubItems.get_children():
		sub_item.save_to_disk(file, depth + 1)


func load_from_disk(line : String) -> void:
	while line.begins_with("    "):
		line = line.right(-4)
		get_item_list().indent_todo(self)

	if line.begins_with("[ ] "):
		line = line.right(-4)
	elif line.begins_with("[x] "):
		self.state = States.DONE
		line = line.right(-4)
	elif line.begins_with("[-] "):
		self.state = States.FAILED
		line = line.right(-4)

	if line.begins_with("> "):
		line = line.right(-2)
		self.set_deferred("is_folded", true)

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

	if self.is_folded:
		%FoldHeading/Tooltip.text = "Unfold Sub-Items"
	else:
		%FoldHeading/Tooltip.text = "Fold Sub-Items"


func _input(event: InputEvent) -> void:
	if is_in_edit_mode():
		if event.is_action_pressed("toggle_todo", false, true):
			if not is_heading:
				self.state = States.DONE if self.state != States.DONE else States.TO_DO
		elif event.is_action_pressed("cancel_todo", false, true):
			if not is_heading:
				self.state = States.FAILED if self.state != States.FAILED else States.TO_DO
		elif event.is_action_pressed("previous_todo", true, true):
			var predecessor = get_item_list().get_predecessor_todo(self)
			if predecessor:
				predecessor.edit()
		elif event.is_action_pressed("next_todo", true, true):
			var successor = get_item_list().get_successor_todo(self)
			if successor:
				successor.edit()
		elif event.is_action_pressed("move_todo_up", true, true):
			get_item_list().move_todo_up(self)
		elif event.is_action_pressed("move_todo_down", true, true):
			get_item_list().move_todo_down(self)
		elif event.is_action_pressed("indent_todo", false, true):
			get_item_list().indent_todo(self)
		elif event.is_action_pressed("indent_todo", true, true):
			pass  # consume echo events without doing anything
		elif event.is_action_pressed("unindent_todo", false, true):
			get_item_list().unindent_todo(self)
		elif event.is_action_pressed("unindent_todo", true, true):
			pass  # consume echo events without doing anything
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


func _on_bookmark_indicator_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		edit()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		%Edit.release_focus()


# NOTE: `tree_exiting` will be emitted both when this panel is about to be removed from the tree
# because the user scrolled the list' view, as well as on a NOTIFICATION_WM_CLOSE_REQUEST, but also
# when an item is deleted (which is why we check if it's queded for deletion first).
func _on_tree_exiting() -> void:
	if not is_queued_for_deletion():
		# submit any yet unsubmitted changes
		if %Edit.text != self.text:
			self.text = %Edit.text


func _apply_state_relative_formatting(immediate := false) -> void:
	if Settings.hide_ticked_off_todos:
		if state != States.TO_DO:
			if not _has_unticked_sub_todos():
				if immediate:
					self.hide()
				else:
					if hide_tween:
						hide_tween.kill()
					modulate.a = 1.0
					hide_tween = create_tween().set_parallel()
					hide_tween.tween_property(%CheckBox, "modulate:a", 0.0, 1.5)
					hide_tween.tween_property(%Content, "modulate:a", 0.0, 1.5)
					await hide_tween.finished
					self.hide()

					if is_in_edit_mode():
						var successor = get_item_list().get_successor_todo(self)
						if successor:
							successor.edit()
						else:
							var predecessor = get_item_list().get_predecessor_todo(self)
							if predecessor:
								predecessor.edit()

					var parent_todo := get_parent_todo()
					if parent_todo and parent_todo.state != States.TO_DO:
						parent_todo._apply_state_relative_formatting()
		else:
			if hide_tween:
				hide_tween.kill()
				%CheckBox.modulate.a = 1.0
				%Content.modulate.a = 1.0
	else:
		if hide_tween:
			hide_tween.kill()
			%CheckBox.modulate.a = 1.0
			%Content.modulate.a = 1.0
		if not is_folded:
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
		var predecessor := get_item_list().get_child(self.get_index() - 1)
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
	var SUCCESSOR_IDS := range(get_index() + 1, get_item_list().get_child_count())
	for successor_id in SUCCESSOR_IDS:
		var successor = get_item_list().get_child(successor_id)
		if successor.indentation_level <= indentation_level:
			break # end of scope reached
		if successor.state == States.TO_DO:
			return true

	return false


func get_parent_todo() -> Control:
	if self.get_item_list().name != "SubItems":
		return null

	var parent := get_parent()
	while parent is not ToDoItem and parent != null:
		parent = parent.get_parent()

	return parent


func get_item_list() -> VBoxContainer:
	return get_parent()


func get_to_do_list() -> ToDoList:
	var parent := get_parent()
	while parent is not ToDoList and parent != null:
		parent = parent.get_parent()
	return parent


func get_day_panel() -> DayPanel:
	var parent := get_parent()
	while parent is not DayPanel and parent != null:
		parent = parent.get_parent()
	return parent


func _on_sub_item_added() -> void:
	is_folded = false

	%CheckBox.hide()
	%FoldHeading.show()

	_update_extra_info()


func _on_sub_item_removed() -> void:
	if %SubItems.get_child_count() == 0:
		%CheckBox.show()
		%FoldHeading.hide()

	_update_extra_info()


func get_sub_item_count() -> int:
	var sub_item_count := 0

	for sub_item in %SubItems.get_children():
		sub_item_count += 1 + sub_item.get_sub_item_count()

	return sub_item_count


func _update_extra_info() -> void:
	var sub_item_count := get_sub_item_count()
	%ExtraInfo.text = "(%d)" % sub_item_count
	%ExtraInfo.visible = (sub_item_count > 0)


func get_sub_item(index: int) -> Node:
	return get_node("%SubItems").get_child(index)
