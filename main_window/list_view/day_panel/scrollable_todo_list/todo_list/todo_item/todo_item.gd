class_name ToDoItem
extends VBoxContainer


# helper variables required by _on_items_child_order_changed, in item_list.gd
@onready var last_index := get_list_index()
@onready var last_date := date

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
		var old_text = text

		if value != old_text:
			if text == "" and not get_day_panel():
				# a new item has been added to the capture list
				review_date = DayTimer.today.add_days(1).as_string()

			text = value

			%Edit.text = _strip_text(text)

			if _initialization_finished:
				get_to_do_list()._start_debounce_timer("text changed")

			_update_saved_search_results(self.date.as_string(), text, old_text)

enum States { TO_DO, DONE, FAILED }
var state := States.TO_DO:
	set(value):
		if state == value:
			return

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

			if indentation_level:
				get_parent_todo()._adapt_sub_item_state()

			if not _is_mouse_over_checkbox:
				if self.state == States.DONE:
					%CheckBox.theme_type_variation = "ToDoItem_Done"
				elif self.state == States.FAILED:
					%CheckBox.theme_type_variation = "ToDoItem_Failed"
				else:
					%CheckBox.theme_type_variation = "ToDoItem"

			if _initialization_finished:
				_apply_state_relative_formatting()

				if date and is_bookmarked:
					EventBus.bookmark_changed.emit(self, date, get_list_index())

				if self.text and not has_sub_items():
					get_to_do_list()._start_debounce_timer("state changed")

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

var _is_mouse_over_checkbox := false

var is_folded := false:
	set(value):
		if is_folded == value:
			return  # early

		if %SubItems.is_empty():
			return  # early

		is_folded = value

		%FoldHeading.set_pressed_no_signal(value)

		_update_extra_info()

		if is_folded:
			%SubItems.visible = contains_search_query_match()
			%ExtraInfo.visible = \
				Settings.show_sub_item_count != Settings.ShowSubItemCount.NEVER
		else:
			%SubItems.show()
			%ExtraInfo.visible = \
				Settings.show_sub_item_count == Settings.ShowSubItemCount.ALWAYS

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

var indentation_level := 0


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

var has_requested_bookmark_update := false

var review_date : String

@onready var review_date_reg_ex := RegEx.new()


func _ready() -> void:
	_set_initial_state()
	_connect_signals()

	%BookmarkIndicator.hide()
	%CopyToToday.modulate.a = 0.1
	%DragHandle.modulate.a = 0.1

	# deferred for two frames, in case this item is loaded from disk
	await get_tree().process_frame
	await get_tree().process_frame
	_initialization_finished = true

	_update_copy_to_today_visibility()

	Settings.fade_ticked_off_todos_changed.connect(_apply_state_relative_formatting)


func _set_initial_state() -> void:
	review_date_reg_ex.compile("\\[REVIEW:(?<date>[0-9]{4}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01]))\\]$")

	%CheckBox.show()
	%FoldHeading.hide()
	%ExtraInfo.hide()

	_on_fold_heading_toggled(self.is_folded)

	_apply_state_relative_formatting.call_deferred(true)

	%MainRow.set_drag_forwarding(Callable(), _can_drop_data, _drop_data)

	# If there's an active search query when initializing this to-do (caused by
	# e.g. scrolling the list view during a search)...
	if Settings.search_query:
		# ... we need to check if this to-do matches that query.
		# NOTE: Deferred, as the text isn't initialized yet.
		_check_for_search_query_match.call_deferred()


func _connect_signals() -> void:
	#region Global Signals
	EventBus.today_changed.connect(_update_copy_to_today_visibility)

	Settings.search_query_changed.connect(_check_for_search_query_match)

	Settings.hide_ticked_off_todos_changed.connect(
		_apply_state_relative_formatting.bind(true)
	)

	Settings.to_do_text_colors_changed.connect(func():
		if text_color_id:
			var color = Settings.to_do_text_colors[text_color_id - 1]
			%Edit.add_theme_color_override("font_placeholder_color", Color(color, 0.7))
			%Edit.add_theme_color_override("font_color", color)
	)

	Settings.show_sub_item_count_changed.connect(func():
		self.is_folded = self.is_folded
	)
	#endregion

	#region Local Signals
	focus_exited.connect(_on_focus_exited)
	tree_exiting.connect(_on_tree_exiting)

	%MainRow.mouse_entered.connect(_on_mouse_entered)
	%MainRow.mouse_exited.connect(_on_mouse_exited)

	%CheckBox.gui_input.connect(_on_check_box_gui_input)
	%CheckBox.mouse_entered.connect(_on_check_box_mouse_entered)
	%CheckBox.mouse_exited.connect(_on_check_box_mouse_exited)

	%FoldHeading.toggled.connect(_on_fold_heading_toggled)
	%FoldHeading.mouse_entered.connect(_on_fold_heading_mouse_entered)
	%FoldHeading.mouse_exited.connect(_on_fold_heading_mouse_exited)

	%Edit.text_changed.connect(_on_edit_text_changed)
	%Edit.text_submitted.connect(_on_edit_text_submitted)
	%Edit.focus_entered.connect(_on_edit_focus_entered)
	%Edit.focus_exited.connect(_on_edit_focus_exited)
	%Edit.gui_input.connect(_on_edit_gui_input)
	%Edit.resized.connect(_on_edit_resized)

	%CopyToToday.mouse_entered.connect(func():
		%CopyToToday.theme_type_variation = "ToDoItem_Focused"
		%CopyToToday.modulate.a = 1.0
	)
	%CopyToToday.pressed.connect(func():
		self.text = %Edit.text

		Cache.copy_item(
			get_list_index(),
			date.as_string(),
			DayTimer.today.as_string()
		)

		Overlay.spawn_toast("To-do copied to today")
	)
	%CopyToToday.mouse_exited.connect(func():
		%CopyToToday.theme_type_variation = "FlatButton"
		%CopyToToday.modulate.a = 0.1
	)

	%BookmarkIndicator.gui_input.connect(_on_bookmark_indicator_gui_input)

	%SubItems.child_entered_tree.connect(_on_sub_item_added.unbind(1))
	%SubItems.child_exiting_tree.connect(_on_sub_item_removed)

	$UnfoldTimer.timeout.connect(func(): is_folded = false)
	#endregion


func is_in_edit_mode() -> bool:
	return has_node("EditingOptions")


func edit() -> void:
	if not is_visible_in_tree():
		var parent_todo := get_parent_todo()
		while parent_todo:
			if parent_todo.is_folded:
				parent_todo.is_folded = false
			parent_todo = parent_todo.get_parent_todo()

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
		# NOTE: We *must* get this now, as the method would simply return `null`
		# once this node got succesfully free'd and exited the tree!
		var to_do_list := get_to_do_list()

		await tree_exited

		to_do_list._start_debounce_timer("to-do deleted")
		_update_saved_search_results(to_do_list.cache_key, text)


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

	_update_copy_to_today_visibility()

	if new_text.begins_with("- "):
		get_item_list().indent_todo(self)
		%Edit.text = new_text.right(-2).strip_edges()

	if date and is_bookmarked:
		EventBus.bookmark_changed.emit(self, date, get_list_index())

	_check_for_search_query_match()


func _strip_text(raw_text: String) -> String:
	# trim any leading & trailing whitespace
	raw_text = raw_text.strip_edges()

	# Check if the text contains any tags (like a bookmark or a color tag) or
	# markup (like asterisks or underscores), and if so, trigger their effect
	# and then remove them from the text.
	while true:
		if raw_text.ends_with("[BOOKMARK]"):
			raw_text = raw_text.left(-10).strip_edges()
			is_bookmarked = true
			continue  # from the start of the while loop again

		var color_tag_reg_ex := RegEx.new()
		color_tag_reg_ex.compile("\\[COLOR(?<digit>[1-5])\\]$")
		var color_tag_reg_ex_match := color_tag_reg_ex.search(raw_text)
		if color_tag_reg_ex_match:
			raw_text = raw_text.substr(0, raw_text.length() - 9).strip_edges()
			text_color_id = int(color_tag_reg_ex_match.get_string("digit"))
			continue  # from the start of the while loop again

		var review_date_reg_ex_match := review_date_reg_ex.search(raw_text)
		if review_date_reg_ex_match:
			raw_text = raw_text.substr(0, raw_text.length() - 20).strip_edges()
			review_date = review_date_reg_ex_match.get_string("date")
			continue  # from the start of the while loop again

		# NOTE: The following two if-conditions do *not* check if the matching
		# parts in the beginning and end of the raw text are distinct. This is
		# intended! It will also strip *any* number of asterisks or underscores
		# when the raw text only contains those and nothing else.

		if raw_text.begins_with("**") and raw_text.ends_with("**") or \
			raw_text.begins_with("__") and raw_text.ends_with("__"):
				raw_text = raw_text.left(-2).right(-2).strip_edges()
				is_bold = true
				continue  # from the start of the while loop again

		if raw_text.begins_with("*") and raw_text.ends_with("*") or \
			raw_text.begins_with("_") and raw_text.ends_with("_"):
				raw_text = raw_text.left(-1).right(-1).strip_edges()
				is_italic = true
				continue  # from the start of the while loop again

		break  # the while loop, nothing to replace was found anymore

	return raw_text


func _on_edit_text_submitted(new_text: String, key_input := true) -> void:
	# save caret_column value, as it will be reset once %Edit.text is set
	set_meta("caret_position", %Edit.caret_column)

	new_text = _strip_text(new_text)
	if %Edit.text != new_text:
		%Edit.text = new_text
		_on_edit_text_changed(new_text)

	var new_item := (self.text == "")

	if new_text:
		self.text = new_text

		%Edit.caret_column = 0   # scroll item text back to its beginning

		if not Utils.is_mouse_cursor_above(self):
			%CopyToToday.modulate.a = 0.1
			%DragHandle.modulate.a = 0.1

		if key_input:
			if Input.is_action_pressed("add_todo_above", true):
				get_item_list().add_todo_above(self)
			elif Input.is_action_pressed("add_todo_below", true) or new_item:
				if new_text.ends_with(":"):
					get_item_list().add_sub_item(self)
				else:
					get_item_list().add_todo_below(self)
			else:
				%Edit.release_focus()
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
			if not get_viewport().gui_get_focus_owner():
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_focus_exited() -> void:
	_on_edit_focus_exited()


func as_string(depth := 0) -> String:
	var unformatted_text : String
	if is_in_edit_mode():
		unformatted_text = %Edit.text
	else:
		unformatted_text = self.text

	if unformatted_text == "":
		return ""

	var result := ""

	for i in depth:
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
	result += unformatted_text
	if is_bold:
		result += "**"
	if is_italic:
		result += "*"

	if is_bookmarked:
		result += " [BOOKMARK]"

	if text_color_id:
		result += " [COLOR%d]" % text_color_id

	if review_date:
		result += " [REVIEW:%s]" % review_date

	for sub_item in %SubItems.get_children():
		result += "\n" + sub_item.as_string(depth + 1)

	return result


func load_from_string(line: String) -> void:
	while line.begins_with("    "):
		line = line.right(-4)
		get_item_list().indent_todo(self, false)

	# strip any remaining spaces on the left
	line = line.strip_edges(true, false)

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
	else:
		self.set_deferred("is_folded", false)

	line = _strip_text(line)

	if line.is_empty():
		queue_free()  # forbidden or no text

	self.text = line


func _on_mouse_entered() -> void:
	if get_viewport().gui_is_dragging():
		if _can_drop_data(
			get_global_mouse_position(),
			get_viewport().gui_get_drag_data()
		):
			%MainRow.theme_type_variation = "ToDoItem_MainRow_Focused"
			$UnfoldTimer.start()
	else:
		%CopyToToday.modulate.a = 1.0

		%DragHandle.theme_type_variation = "ToDoItem_Focused"
		%DragHandle.modulate.a = 1.0


func _on_mouse_exited() -> void:
	if not is_queued_for_deletion():
		%DragHandle.theme_type_variation = "FlatButton"

		if not is_in_edit_mode():
			%CopyToToday.modulate.a = 0.1
			%DragHandle.modulate.a = 0.1

	if get_viewport().gui_is_dragging():
		%MainRow.theme_type_variation = "ToDoItem_MainRow"
		$UnfoldTimer.stop()


func _on_fold_heading_toggled(toggled_on: bool) -> void:
	self.is_folded = toggled_on

	if self.is_folded:
		%FoldHeading/Tooltip.text = "Unfold Sub-Items"
	else:
		%FoldHeading/Tooltip.text = "Fold Sub-Items"


func _input(event: InputEvent) -> void:
	if is_in_edit_mode():
		if event.is_action_pressed("toggle_todo", false, true):
			if %SubItems.is_empty():
				self.state = States.DONE if self.state != States.DONE else States.TO_DO
			else:
				is_folded = not is_folded
		elif event.is_action_pressed("toggle_todo", true, true):
			pass  # consume echo events without doing anything
		elif event.is_action_pressed("cancel_todo", false, true):
			if %SubItems.is_empty():
				self.state = States.FAILED if self.state != States.FAILED else States.TO_DO
			else:
				is_folded = not is_folded
		elif event.is_action_pressed("cancel_todo", true, true):
			pass  # consume echo events without doing anything
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


func _check_for_search_query_match() -> void:
	var parent_todo := get_parent_todo()

	if not Settings.search_query:
		# restore the to-do's text color
		text_color_id = text_color_id
		%Edit.theme_type_variation = "LineEdit_Minimal"
		if Settings.fade_ticked_off_todos and state != States.TO_DO:
			%Edit.modulate.a = 0.5
		else:
			%Edit.modulate.a = 1.0

		if parent_todo and parent_todo.is_folded:
			# If the sub items list was temporarily made visible again, as it
			# contained a matching item (see elif-case below), hide it again.
			parent_todo.get_node("%SubItems").hide()
	elif %Edit.text.contains(Settings.search_query):
		# remove the to-do's text color, if there's any (or it would overrule
		# the highlighting color of the search match)
		%Edit.remove_theme_color_override("font_color")
		%Edit.theme_type_variation = "LineEdit_SearchMatch"
		%Edit.modulate.a = 1.0

		if not is_visible_in_tree():
			# Temporarily overrule the is_folded state, and make the sub items
			# list (and therefore: this matching item) visible again.
			# NOTE: Called deferred, to make sure it's called *after* potential
			# other, non-matching sub items, which would otherwise immediately
			# undo this change again (see the else-case below).
			while parent_todo:
				if parent_todo.is_folded:
					parent_todo.get_node("%SubItems").show.call_deferred()
				parent_todo = parent_todo.get_parent_todo()
	else:
		# restore the to-do's text color
		text_color_id = text_color_id
		%Edit.theme_type_variation = "LineEdit_Minimal"
		%Edit.modulate.a = 0.1

		if parent_todo and parent_todo.is_folded:
			# If the sub items list was temporarily made visible again, as it
			# contained a matching item (see elif-case above), hide it again.
			parent_todo.get_node("%SubItems").hide()


func _on_bookmark_indicator_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
			event.button_index == MOUSE_BUTTON_LEFT and \
					event.is_released():
		Settings.side_panel = Settings.SidePanelState.BOOKMARKS
		EventBus.bookmark_indicator_clicked.emit(date, get_list_index())


# NOTE: `tree_exiting` will be emitted both when this panel is about to be removed from the tree
# because the user scrolled the list' view, as well as on a NOTIFICATION_WM_CLOSE_REQUEST, but also
# when an item is deleted (which is why we check if it's queded for deletion first).
func _on_tree_exiting() -> void:
	if not is_queued_for_deletion():
		self.text = %Edit.text  # submit any yet unsubmitted changes


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
					hide_tween.tween_property(%Toggle, "modulate:a", 0.0, 1.5)
					hide_tween.tween_property(%Edit, "modulate:a", 0.0, 1.5)
					hide_tween.tween_property(%ExtraInfo, "modulate:a", 0.0, 1.5)
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
				%Toggle.modulate.a = 1.0
				%Edit.modulate.a = 1.0
				%ExtraInfo.modulate.a = 1.0
	else:
		if hide_tween:
			hide_tween.kill()
			%Toggle.modulate.a = 1.0
			%Edit.modulate.a = 1.0
			%ExtraInfo.modulate.a = 1.0
		if not is_folded:
			self.show()

		if Settings.fade_ticked_off_todos:
			if state != States.TO_DO:
				%Toggle.modulate.a = 0.5
				if not Settings.search_query:
					%Edit.modulate.a = 0.5
				%ExtraInfo.modulate.a = 0.5
			else:
				%Toggle.modulate.a = 1.0
				if not Settings.search_query:
					%Edit.modulate.a = 1.0
				%ExtraInfo.modulate.a = 1.0
		else:
			%Toggle.modulate.a = 1.0
			%Edit.modulate.a = 1.0
			%ExtraInfo.modulate.a = 1.0


func _on_edit_gui_input(event: InputEvent) -> void:
	# Only allow focusing the edit field via left-clicks (by default, pressing
	# the right or middle mouse button will work as well)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			accept_event()
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			# If the edit field is already focused, middle clicking it should
			# paste the clipboard content – so we can't accept it then!
			if not %Edit.has_focus():
				accept_event()

	if event.is_action_pressed("ui_text_backspace") and %Edit.text == "":
		get_item_list().unindent_todo(self)

	if event.is_action_pressed("ui_cancel"):
		%Edit.release_focus()


func _has_unticked_sub_todos() -> bool:
	for sub_item in %SubItems.get_children():
		if sub_item.state == States.TO_DO:
			return true
		else:
			if sub_item._has_unticked_sub_todos():
				return true

	return false


func get_parent_todo() -> ToDoItem:
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
	%CheckBox.hide()
	%FoldHeading.show()

	_adapt_sub_item_state()


func _on_sub_item_removed(sub_item: ToDoItem) -> void:
	var day_panel := get_day_panel()

	if day_panel and not day_panel.is_queued_for_deletion():
		# at this point, the sub item is still part of the tree
		if sub_item.is_bookmarked:
			EventBus.bookmark_changed.emit.call_deferred(
				sub_item,
				sub_item.date,
				sub_item.get_list_index()
			)
			sub_item.has_requested_bookmark_update = true

	await get_tree().process_frame

	# now, the sub item is no longer part of the tree
	if %SubItems.is_empty():
		%CheckBox.show()
		%FoldHeading.hide()

	_adapt_sub_item_state()


func get_sub_item_count() -> int:
	var sub_item_count := 0

	for sub_item in %SubItems.get_children():
		sub_item_count += 1 + sub_item.get_sub_item_count()

	return sub_item_count


func get_done_items_count() -> int:
	var done_items_count := 0

	for sub_item in %SubItems.get_children():
		if sub_item.state != States.TO_DO:
			done_items_count += 1

		done_items_count += sub_item.get_done_items_count()

	return done_items_count


func _update_extra_info() -> void:
	var sub_item_count := get_sub_item_count()
	var done_items_count := get_done_items_count()

	%ExtraInfo.text = "(%d/%d)" % [done_items_count, sub_item_count]


func has_sub_items() -> bool:
	return get_node("%SubItems").get_child_count()


func get_sub_item(index: int) -> Variant:
	for sub_item in %SubItems.get_children():
		if index == 0:
			return sub_item
		else:
			index -= 1

		var result = sub_item.get_sub_item(index)
		if result is ToDoItem:
			return result
		else:
			index = result

	return index


func _adapt_sub_item_state() -> void:
	if %SubItems.is_empty():
		self.state = States.TO_DO
	else:
		if _has_unticked_sub_todos():
			self.state = States.TO_DO
		else:
			self.state = States.DONE


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# prevents the user from dropping a to-do on itself or its own sub items
	return data is ToDoItem and data != self and not data.is_ancestor_of(self)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	%MainRow.theme_type_variation = "ToDoItem_MainRow"

	if data.get_parent_todo() == self:
		# If a to-do is dropped on its parent to-do, move the to-do to the
		# end of the item list of its parent to-do (if it isn't already).
		%SubItems.move_child(data, -1)
	else:
		# Otherwise, add it to (the end of) this item's sub item list.
		%SubItems._drop_data(Vector2(0, %SubItems.size.y), data)


func contains_search_query_match() -> bool:
	if not Settings.search_query:
		return false

	if get_node("%Edit").text.contains(Settings.search_query):
		return true

	for sub_item in %SubItems.get_children():
		if sub_item.contains_search_query_match():
			return true

	return false


func get_list_index() -> int:
	return get_to_do_list().get_line_number_for_item(self)


func _on_check_box_mouse_entered() -> void:
	_is_mouse_over_checkbox = true

	%CheckBox.theme_type_variation = "ToDoItem_Focused"


func _on_check_box_mouse_exited() -> void:
	_is_mouse_over_checkbox = false

	if self.state == States.DONE:
		%CheckBox.theme_type_variation = "ToDoItem_Done"
	elif self.state == States.FAILED:
		%CheckBox.theme_type_variation = "ToDoItem_Failed"
	else:
		%CheckBox.theme_type_variation = "ToDoItem"


func _on_fold_heading_mouse_entered() -> void:
	%FoldHeading.theme_type_variation = "ToDoItem_Focused"


func _on_fold_heading_mouse_exited() -> void:
	%FoldHeading.theme_type_variation = "FlatButton"


func _update_copy_to_today_visibility():
	%CopyToToday.visible = %Edit.text != "" and \
			date.day_difference_to(DayTimer.today) < 0


func _update_saved_search_results(cache_key: String, new_text: String, old_text := "") -> void:
	if not _initialization_finished:
		return  # early

	if "saved_searches" in Cache.data:
		for raw_query in Cache.data["saved_searches"].content:
			var alarm_tag_reg_ex := RegEx.new()
			alarm_tag_reg_ex.compile("\\[ALARM:(?<alarm>[\\+|-][1-9][0-9]*)\\]$")
			var query := alarm_tag_reg_ex.sub(raw_query, "").strip_edges()

			if old_text.contains(query) or new_text.contains(query):
				EventBus.instant_save_requested.emit(
					cache_key
				)
				EventBus.saved_search_update_requested.emit(query)
