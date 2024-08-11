extends PanelContainer

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
			%Label.text = text
			if self.is_heading:
				%Edit.text = "# " + text
			else:
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
				for node in [%Content, %Label, %Edit]:
					node.mouse_default_cursor_shape = CURSOR_IBEAM
			else:
				%CheckBox.modulate.a = 0.5
				%Content.modulate.a = 0.5
				for node in [%Content, %Label, %Edit]:
					node.mouse_default_cursor_shape = CURSOR_ARROW

@export var is_heading := false:
	set(value):
		is_heading = value
		if is_inside_tree():
			if is_heading:
				get("theme_override_styles/panel").draw_center = true
				%Label.uppercase = true
				%FoldHeading.show()
				%CheckBox.hide()
			else:
				get("theme_override_styles/panel").draw_center = false
				%Label.uppercase = false
				%FoldHeading.hide()
				%CheckBox.show()


var _contains_mouse_cursor := false

var is_folded := false:
	set(value):
		is_folded = value

		if not is_node_ready():
			await self.ready

		%FoldHeading.button_pressed = is_folded

		if is_folded:
			# FIXME: Starting with Godot 4.3, `self.folded.emit.call_deferred()` will work, too!
			(func(): self.folded.emit()).call_deferred()
			$HBox/ExtraInfo.show()
		else:
			# FIXME: Starting with Godot 4.3, `self.unfolded.emit.call_deferred()` will work, too!
			(func(): self.unfolded.emit()).call_deferred()
			$HBox/ExtraInfo.hide()


func _ready() -> void:
	# manually trigger setters
	text = text
	state = state

	%Edit.hide()
	%Label.show()

	%UI.visible = _contains_mouse_cursor

	_on_dark_mode_changed(Settings.dark_mode)
	EventBus.dark_mode_changed.connect(_on_dark_mode_changed)


func is_in_edit_mode() -> bool:
	return %Edit.visible


func edit() -> void:
	for child in $HBox/Toggle.get_children():
		child.mouse_default_cursor_shape = CURSOR_FORBIDDEN
		child.disabled = true
	%Label.hide()
	%Edit.show()
	%UI.hide()
	%Edit.caret_column = %Edit.text.length()
	%Edit.grab_focus()
	editing_started.emit()


func delete() -> void:
	self.unfolded.emit()
	queue_free()
	if self.text:
		await tree_exited
		changed.emit()


func _on_edit_text_changed(new_text: String) -> void:
	is_heading = new_text.begins_with("# ")


func _on_edit_text_submitted(new_text: String, key_input := true) -> void:
	if new_text.begins_with("# "):
		new_text = new_text.right(-2)

	# trim any leading & trailing whitespace
	new_text = new_text.strip_edges()

	var new_item := (self.text == "")

	if new_text:
		if self.text != new_text:
			self.text = new_text
			changed.emit()
		%Edit.hide()
		%Label.show()
		for child in $HBox/Toggle.get_children():
			child.mouse_default_cursor_shape = CURSOR_POINTING_HAND
			child.disabled = false
		if _contains_mouse_cursor:
			%UI.show()

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
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MASK_LEFT:
				if event.pressed and self.state == States.TO_DO:
					edit()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return get_node("../../..")._can_drop_data(_at_position, data)


func _drop_data(at_position: Vector2, data: Variant) -> void:
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
	string += text

	file.store_line(string)


func load_from_disk(line : String) -> void:
	if line.begins_with("# ") or line.begins_with("v "):
		self.text = line.right(-2)
		self.is_heading = true
		self.is_folded = false
	elif line.begins_with("> "):
		self.text = line.right(-2)
		self.is_heading = true
		self.is_folded = true
	elif line.begins_with("[ ] "):
		self.text = line.right(-4)
	elif line.begins_with("[x] "):
		self.state = States.DONE
		self.text = line.right(-4)
	elif line.begins_with("[-] "):
		self.state = States.FAILED
		self.text = line.right(-4)
	else:
		push_warning("Unknown format for line \"%s\" (will be automatically converted into a todo)" % line)
		self.text = line


func _on_mouse_entered() -> void:
	_contains_mouse_cursor = true
	%Label.set("theme_override_colors/font_color", Settings.NORD_09)
	$HBox/ExtraInfo/Label.set("theme_override_colors/font_color", Settings.NORD_09)
	%CheckBox.set("theme_override_colors/icon_normal_color", Settings.NORD_09)
	%CheckBox.set("theme_override_colors/icon_hover_color", Settings.NORD_09)
	%CheckBox.set("theme_override_colors/icon_pressed_color", Settings.NORD_10)
	%FoldHeading.set("theme_override_colors/icon_normal_color", Settings.NORD_09)
	%FoldHeading.set("theme_override_colors/icon_hover_color", Settings.NORD_09)
	%FoldHeading.set("theme_override_colors/icon_pressed_color", Settings.NORD_10)
	if not is_in_edit_mode() and self.state == States.TO_DO and not get_viewport().gui_is_dragging():
		%UI.show()


func _on_mouse_exited() -> void:
	_contains_mouse_cursor = false
	if not is_queued_for_deletion():
		# Temporarily disabling the delete button is necessary here to avoid a rather bizarre bug(?)
		# when clicking the button, keeping the button pressed and then moving the mouse cursor out
		# of the top or bottom side of the to-do item. This will result in hiding the UI (including
		# the delete button) and trigger the button's `pressed` signal (even though the mouse button
		# is still held down!), thus would delete the to-do item. Disabling the button while hiding
		# the UI prevents this from happening and cancels the action.
		%UI/Delete.disabled = true
		%UI.hide()
		%UI/Delete.disabled = false

		var icon_color := Settings.NORD_06 if Settings.dark_mode else Settings.NORD_00
		if self.state == States.DONE:
			icon_color = Color("#A3BE8C")
		elif self.state == States.FAILED:
			icon_color = Color("#BF616A")

		if Settings.dark_mode:
			%Label.set("theme_override_colors/font_color", Settings.NORD_06)
			$HBox/ExtraInfo/Label.set("theme_override_colors/font_color", Settings.NORD_06)
			for toggle in [%CheckBox, %FoldHeading]:
				toggle.set("theme_override_colors/icon_normal_color", icon_color)
				toggle.set("theme_override_colors/icon_hover_color", icon_color)
				toggle.set("theme_override_colors/icon_pressed_color", icon_color)
		else:
			%Label.set("theme_override_colors/font_color", Settings.NORD_06)
			$HBox/ExtraInfo/Label.set("theme_override_colors/font_color", Settings.NORD_06)
			for toggle in [%CheckBox, %FoldHeading]:
				toggle.set("theme_override_colors/icon_normal_color", icon_color)
				toggle.set("theme_override_colors/icon_hover_color", icon_color)
				toggle.set("theme_override_colors/icon_pressed_color", icon_color)


func _on_dark_mode_changed(dark_mode : bool) -> void:
	if dark_mode:
		get("theme_override_styles/panel").bg_color = Settings.NORD_02
		%Label.set("theme_override_colors/font_color", Settings.NORD_06)
		$HBox/ExtraInfo/Label.set("theme_override_colors/font_color", Settings.NORD_06)
		%UI/Delete.set("theme_override_colors/icon_normal_color", Settings.NORD_06)
		%UI/DragHandle.modulate = Settings.NORD_06
	else:
		get("theme_override_styles/panel").bg_color = Settings.NORD_04
		%Label.set("theme_override_colors/font_color", Settings.NORD_00)
		$HBox/ExtraInfo/Label.set("theme_override_colors/font_color", Settings.NORD_00)
		%UI/Delete.set("theme_override_colors/icon_normal_color", Settings.NORD_00)
		%UI/DragHandle.modulate = Settings.NORD_00


func _on_fold_heading_toggled(toggled_on: bool) -> void:
	self.is_folded = toggled_on


func set_extra_info(num_done : int , num_items : int) -> void:
	$HBox/ExtraInfo/Label.text = "%d/%d" % [num_done, num_items]


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var focus_owner := get_viewport().gui_get_focus_owner()
		if focus_owner and not focus_owner.owner == self:
			focus_owner.release_focus()


func _on_check_box_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				self.state = States.DONE if self.state != States.DONE else States.TO_DO
			MOUSE_BUTTON_RIGHT:
				self.state = States.FAILED if self.state != States.FAILED else States.TO_DO
