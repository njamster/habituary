extends PanelContainer

signal create_follow_up

signal editing_started
signal editing_finished

const DEFAULT := preload("resources/default.tres")
const HEADLINE := preload("resources/headline.tres")

@export var text := "":
	set(value):
		text = value
		if is_inside_tree():
			%Label.text = text
			if self.is_heading:
				%Edit.text = "# " + text
			else:
				%Edit.text = text

@export var done := false:
	set(value):
		done = value
		if is_inside_tree():
			if done:
				%Label.self_modulate.a = 0.3
				for node in [%Content, %Label, %Edit]:
					node.mouse_default_cursor_shape = CURSOR_ARROW
			else:
				%Label.self_modulate.a = 1.0
				for node in [%Content, %Label, %Edit]:
					node.mouse_default_cursor_shape = CURSOR_IBEAM

@export var is_heading := false:
	set(value):
		is_heading = value
		if is_inside_tree():
			if is_heading:
				add_theme_stylebox_override("panel", HEADLINE)
				if not _contains_mouse_cursor:
					%Content.modulate = Color("#2E3440")
				%UI.modulate = Color.BLACK
				%Label.uppercase = true
			else:
				add_theme_stylebox_override("panel", DEFAULT)
				if not _contains_mouse_cursor:
					%Content.modulate = Color.WHITE
				%UI.modulate = Color.WHITE
				%Label.uppercase = false


var _contains_mouse_cursor := false


func _ready() -> void:
	text = text # manually trigger setter

	%Edit.hide()
	%Label.show()

	%UI.visible = _contains_mouse_cursor


func is_in_edit_mode() -> bool:
	return %Edit.visible


func edit() -> void:
	%Label.hide()
	%Edit.show()
	%UI.hide()
	%Edit.caret_column = %Edit.text.length()
	%Edit.grab_focus()
	editing_started.emit()


func _on_edit_text_changed(new_text: String) -> void:
	is_heading = new_text.begins_with("# ")


func _on_edit_text_submitted(new_text: String) -> void:
	if new_text.begins_with("# "):
		new_text = new_text.right(-2)

	if new_text:
		self.text = new_text
		%Edit.hide()
		%Label.show()
		if _contains_mouse_cursor:
			%UI.show()
		if Input.is_key_pressed(KEY_SHIFT):
			create_follow_up.emit()
	else:
		%Edit.hide()
		%Label.show()
		if _contains_mouse_cursor:
			%UI.show()


func _on_edit_focus_exited() -> void:
	if %Edit.text:
		if is_heading and %Edit.text == "# ":
			queue_free()
			if self.text:
				await tree_exited
				editing_finished.emit()
		else:
			_on_edit_text_submitted(%Edit.text)
			editing_finished.emit()
	else:
		queue_free()
		if self.text:
			await tree_exited
			editing_finished.emit()


func _on_content_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MASK_LEFT:
				if event.pressed and not done:
					edit()
			MOUSE_BUTTON_MASK_RIGHT:
				if event.pressed and not is_in_edit_mode() and not is_heading:
					done = not done
					%UI.visible = not done


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.is_in_group("todo_item")


func _drop_data(at_position: Vector2, data: Variant) -> void:
	# FIXME: avoid asumptions about the parent's of this node
	get_node("../../..")._drop_data(position - Vector2.ONE, data)


func save_to_disk(file : FileAccess) -> void:
	if not text:
		return

	var string := ""

	if is_heading:
		string += "# "
	elif done:
		string += "[x] "
	else:
		string += "[ ] "
	string += text

	file.store_line(string)


func load_from_disk(line : String) -> void:
	if line.begins_with("# "):
		self.is_heading = true
		self.text = line.right(-2)
	elif line.begins_with("[ ] "):
		self.text = line.right(-4)
	elif line.begins_with("[x] "):
		self.done = true
		self.text = line.right(-4)
	else:
		push_warning("Unknown format for line \"%s\" (will be automatically converted into a todo)" % line)
		self.text = line


func _on_mouse_entered() -> void:
	_contains_mouse_cursor = true
	$HBox/Content.modulate = Color("#81a1c1")
	if not is_in_edit_mode() and not done:
		%UI.show()


func _on_mouse_exited() -> void:
	_contains_mouse_cursor = false
	if not is_queued_for_deletion():
		%UI.hide()
		if is_heading:
			%Content.modulate = Color("#2E3440")
		else:
			%Content.modulate = Color.WHITE


func _on_delete_pressed() -> void:
	queue_free()
	await tree_exited
	editing_finished.emit()
