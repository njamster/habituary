extends VBoxContainer

signal predecessor_requested
signal successor_requested

signal editing_started
signal changed

signal folded
signal unfolded

@export var text := "":
	set(value):
		text = value
		if is_inside_tree():
			%Edit.text = text

enum States { TO_DO, DONE, FAILED }
@export var state := States.TO_DO:
	set(value):
		state = value
		if is_inside_tree():
			if state == States.TO_DO:
				%CheckBox.icon = preload(
					"res://main_window/list_view/day_panel/todo_list/todo_item/images/to_do.svg"
				)
			elif state == States.DONE:
				%CheckBox.icon = preload(
					"res://main_window/list_view/day_panel/todo_list/todo_item/images/done.svg"
				)
			elif state == States.FAILED:
				%CheckBox.icon = preload(
					"res://main_window/list_view/day_panel/todo_list/todo_item/images/failed.svg"
				)

			%CheckBox.button_pressed = (state != States.TO_DO)

			if not _contains_mouse_cursor:
				var icon_color := Settings.NORD_06 if Settings.dark_mode else Settings.NORD_00
				if self.state == States.DONE:
					icon_color = Color("#A3BE8C")
				elif self.state == States.FAILED:
					icon_color = Color("#BF616A")

				for toggle in [%CheckBox, %FoldHeading]:
					toggle.set("theme_override_colors/icon_normal_color", icon_color)
					toggle.set("theme_override_colors/icon_hover_color", icon_color)
					toggle.set("theme_override_colors/icon_pressed_color", icon_color)

			if state == States.TO_DO:
				%CheckBox.modulate.a = 1.0
				%Content.modulate.a = 1.0
				for node in [%Content, %Edit]:
					node.mouse_default_cursor_shape = CURSOR_IBEAM
				%Edit.focus_mode = FOCUS_ALL
				%Edit.selecting_enabled = true
				%Edit.editable = true
			else:
				%CheckBox.modulate.a = 0.5
				%Content.modulate.a = 0.5
				for node in [%Content, %Edit]:
					node.mouse_default_cursor_shape = CURSOR_ARROW
				%Edit.focus_mode = FOCUS_NONE
				%Edit.selecting_enabled = false
				%Edit.editable = false

@export var is_heading := false:
	set(value):
		is_heading = value
		if is_inside_tree():
			if is_heading:
				$MainRow.get("theme_override_styles/panel").draw_center = true
				%Heading.get_node("Tooltip").text = "Undo Heading"
				%Delete.text = "Delete Heading"
				%FoldHeading.show()
				%CheckBox.hide()
			else:
				if is_folded:
					is_folded = false
				$MainRow.get("theme_override_styles/panel").draw_center = false
				%Heading.get_node("Tooltip").text = "Make Heading"
				%Delete.text = "Delete To-Do"
				%FoldHeading.hide()
				%CheckBox.show()
			_on_editing_options_resized()
			%Heading.button_pressed = is_heading

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


func _ready() -> void:
	# manually trigger setters
	text = text
	state = state

	_apply_formatting()

	$Triangle.hide()
	%EditingOptions.hide()
	%DragHandle.visible = _contains_mouse_cursor

	_on_dark_mode_changed(Settings.dark_mode)
	EventBus.dark_mode_changed.connect(_on_dark_mode_changed)

	EventBus.search_query_changed.connect(_check_for_search_query_match)


func is_in_edit_mode() -> bool:
	return %Edit.has_focus()


func edit() -> void:
	for child in %Toggle.get_children():
		child.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		child.disabled = true
	%Edit.grab_focus()
	$Triangle.show()
	%EditingOptions.show()
	editing_started.emit()


func delete() -> void:
	self.unfolded.emit()
	queue_free()
	if self.text:
		await tree_exited
		changed.emit()


func _on_edit_text_submitted(new_text: String, key_input := true) -> void:
	# trim any leading & trailing whitespace
	new_text = new_text.strip_edges()

	var new_item := (self.text == "")

	if new_text:
		if self.text != new_text:
			self.text = new_text
			_check_for_search_query_match()
			changed.emit()
		%Edit.release_focus()
		%EditingOptions.hide()
		$Triangle.hide()
		for child in %Toggle.get_children():
			child.mouse_default_cursor_shape = CURSOR_POINTING_HAND
			child.disabled = false
		if _contains_mouse_cursor:
			%DragHandle.show()

		if new_item and key_input:
			if Input.is_key_pressed(KEY_SHIFT):
				predecessor_requested.emit()
			else:
				successor_requested.emit()
	else:
		delete()


func _on_edit_focus_exited() -> void:
	if not is_queued_for_deletion() and %Edit.visible:
		_on_edit_text_submitted(%Edit.text, false)


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
	if not text:
		return

	var string := ""

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
	string += text
	if is_bold:
		string += "**"
	if is_italic:
		string += "*"

	file.store_line(string)


func load_from_disk(line : String) -> void:
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

	if line.begins_with("**") and  line.ends_with("**"):
		line = line.substr(2, line.length() - 4)
		is_bold = true
	if line.begins_with("*") and  line.ends_with("*"):
		line = line.substr(1, line.length() - 2)
		is_italic = true

	self.text = line


func _on_mouse_entered() -> void:
	_contains_mouse_cursor = true
	%ExtraInfo.set("theme_override_colors/font_color", Settings.NORD_09)
	%CheckBox.set("theme_override_colors/icon_normal_color", Settings.NORD_09)
	%CheckBox.set("theme_override_colors/icon_hover_color", Settings.NORD_09)
	%CheckBox.set("theme_override_colors/icon_pressed_color", Settings.NORD_10)
	%CheckBox.set("theme_override_colors/icon_disabled_color", Settings.NORD_10)
	%FoldHeading.set("theme_override_colors/icon_normal_color", Settings.NORD_09)
	%FoldHeading.set("theme_override_colors/icon_hover_color", Settings.NORD_09)
	%FoldHeading.set("theme_override_colors/icon_pressed_color", Settings.NORD_10)
	%FoldHeading.set("theme_override_colors/icon_disabled_color", Settings.NORD_10)
	if not is_in_edit_mode() and self.state == States.TO_DO and not get_viewport().gui_is_dragging():
		%DragHandle.show()


func _on_mouse_exited() -> void:
	_contains_mouse_cursor = false
	if not is_queued_for_deletion():
		if not is_in_edit_mode():
			%DragHandle.hide()

		var icon_color := Settings.NORD_06 if Settings.dark_mode else Settings.NORD_00
		if self.state == States.DONE:
			icon_color = Color("#A3BE8C")
		elif self.state == States.FAILED:
			icon_color = Color("#BF616A")

		if Settings.dark_mode:
			%ExtraInfo.set("theme_override_colors/font_color", Settings.NORD_06)
			for toggle in [%CheckBox, %FoldHeading]:
				toggle.set("theme_override_colors/icon_normal_color", icon_color)
				toggle.set("theme_override_colors/icon_hover_color", icon_color)
				toggle.set("theme_override_colors/icon_pressed_color", icon_color)
				toggle.set("theme_override_colors/icon_disabled_color", icon_color)
		else:
			%ExtraInfo.set("theme_override_colors/font_color", Settings.NORD_00)
			for toggle in [%CheckBox, %FoldHeading]:
				toggle.set("theme_override_colors/icon_normal_color", icon_color)
				toggle.set("theme_override_colors/icon_hover_color", icon_color)
				toggle.set("theme_override_colors/icon_pressed_color", icon_color)
				toggle.set("theme_override_colors/icon_disabled_color", icon_color)


func _on_dark_mode_changed(dark_mode : bool) -> void:
	var icon_color := Settings.NORD_06 if Settings.dark_mode else Settings.NORD_00
	if self.state == States.DONE:
		icon_color = Color("#A3BE8C")
	elif self.state == States.FAILED:
		icon_color = Color("#BF616A")

	if dark_mode:
		$MainRow.get("theme_override_styles/panel").bg_color = Settings.NORD_02
		%ExtraInfo.set("theme_override_colors/font_color", Settings.NORD_06)
		for toggle in [%CheckBox, %FoldHeading]:
			toggle.set("theme_override_colors/icon_normal_color", icon_color)
			toggle.set("theme_override_colors/icon_hover_color", icon_color)
			toggle.set("theme_override_colors/icon_pressed_color", icon_color)
			toggle.set("theme_override_colors/icon_disabled_color", icon_color)
		%DragHandle.modulate = Settings.NORD_06
	else:
		$MainRow.get("theme_override_styles/panel").bg_color = Settings.NORD_04
		%ExtraInfo.set("theme_override_colors/font_color", Settings.NORD_00)
		for toggle in [%CheckBox, %FoldHeading]:
			toggle.set("theme_override_colors/icon_normal_color", icon_color)
			toggle.set("theme_override_colors/icon_hover_color", icon_color)
			toggle.set("theme_override_colors/icon_pressed_color", icon_color)
			toggle.set("theme_override_colors/icon_disabled_color", icon_color)
		%DragHandle.modulate = Settings.NORD_00


func _on_fold_heading_toggled(toggled_on: bool) -> void:
	self.is_folded = toggled_on


func set_extra_info(num_done : int , num_items : int) -> void:
	%ExtraInfo.text = "%d/%d" % [num_done, num_items]


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		var focus_owner := get_viewport().gui_get_focus_owner()
		if focus_owner and not focus_owner.owner == self:
			focus_owner.release_focus()


func _on_check_box_gui_input(event: InputEvent) -> void:
	if not is_in_edit_mode() and event is InputEventMouseButton and event.is_released():
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
	if regex1.search(text):
		pass # do nothing
	elif regex2.search(text):
		pass # do nothing
	else:
		# add first time
		var current_time := Time.get_time_string_from_system().left(5)
		text = current_time + ": " + text


func _add_end_time() -> void:
	var regex1 = RegEx.new()
	regex1.compile("^[0-9]{2}:[0-9]{2}: ")
	var result1 = regex1.search(text)
	var regex2 = RegEx.new()
	regex2.compile("^[0-9]{2}:[0-9]{2}–[0-9]{2}:[0-9]{2}: ")
	if result1:
		var current_time := Time.get_time_string_from_system().left(5)
		if result1.get_string(0).left(-2) == current_time:
			# replace first time
			text = current_time + text.right(-5)
		else:
			# keep first time, add second time
			text = text.left(5) + "–" + current_time + text.right(-5)
	elif regex2.search(text):
		var current_time := Time.get_time_string_from_system().left(5)
		# keep first time, replace second time
		text = text.left(5) + "–" + current_time + text.right(-11)
	else:
		# add first time
		var current_time := Time.get_time_string_from_system().left(5)
		text = current_time + ": " + text


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
	if %EditingOptions.size.x < 300:
		%FormatLabel.hide()
		if is_heading:
			%Delete.get_node("Tooltip").text = "Delete Heading"
		else:
			%Delete.get_node("Tooltip").text = "Delete To-Do"
		%Delete.text = ""
	else:
		%FormatLabel.show()
		if is_heading:
			%Delete.text = "Delete Heading"
		else:
			%Delete.text = "Delete To-Do"
		%Delete.get_node("Tooltip").text = ""


func _on_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.ctrl_pressed and event.pressed:
		match event.key_label:
			KEY_H:
				%Heading.button_pressed = not %Heading.button_pressed
				accept_event()
			KEY_B:
				%Bold.button_pressed = not %Bold.button_pressed
				accept_event()
			KEY_I:
				%Italic.button_pressed = not %Italic.button_pressed
				accept_event()
			KEY_D:
				delete()
				accept_event()


func _check_for_search_query_match() -> void:
	if not Settings.search_query:
		%Edit.remove_theme_color_override("font_color")
		%Edit.remove_theme_color_override("font_uneditable_color")
		%Edit.modulate.a = 1.0
	elif text.contains(Settings.search_query):
		%Edit.add_theme_color_override("font_color", Color("#88c0d0"))
		%Edit.add_theme_color_override("font_uneditable_color", Color("#88c0d0"))
		%Edit.modulate.a = 1.0
	else:
		%Edit.remove_theme_color_override("font_color")
		%Edit.remove_theme_color_override("font_uneditable_color")
		%Edit.modulate.a = 0.1
