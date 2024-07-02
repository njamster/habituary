extends PanelContainer

signal create_follow_up

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
				modulate.a = 0.3
			else:
				modulate.a = 1.0

@export var is_heading := false:
	set(value):
		is_heading = value
		if is_inside_tree():
			if is_heading:
				add_theme_stylebox_override("panel", HEADLINE)
				$Label.add_theme_color_override("font_color", "#2E3440")
				$Edit.add_theme_color_override("font_color", "#2E3440")
				$Label.uppercase = true
			else:
				add_theme_stylebox_override("panel", DEFAULT)
				$Label.remove_theme_color_override("font_color")
				$Edit.remove_theme_color_override("font_color")
				$Label.uppercase = false


func _ready() -> void:
	text = text # manually trigger setter

	%Edit.hide()
	%Label.show()


func edit() -> void:
	%Label.hide()
	%Edit.show()
	%Edit.caret_column = %Edit.text.length()
	%Edit.grab_focus()


func _on_edit_text_changed(new_text: String) -> void:
	is_heading = new_text.begins_with("# ")


func _on_edit_text_submitted(new_text: String) -> void:
	if not new_text:
		%Edit.hide()
		%Label.show()
	else:
		if new_text.begins_with("# "):
			new_text = new_text.right(-2)
		self.text = new_text
		%Edit.hide()
		%Label.show()
		if Input.is_key_pressed(KEY_SHIFT):
			create_follow_up.emit()


func _on_edit_focus_exited() -> void:
	if %Edit.text:
		if is_heading and $Edit.text == "# ":
			queue_free()
		else:
			_on_edit_text_submitted(%Edit.text)
	else:
		queue_free()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MASK_LEFT:
				if event.pressed and event.double_click:
					edit()
			MOUSE_BUTTON_MASK_RIGHT:
				if event.pressed and not %Edit.visible and not is_heading:
					done = not done


func _get_drag_data(at_position: Vector2) -> Variant:
	if done:
		return

	var pivot = Control.new()

	var preview = self.duplicate()
	preview.self_modulate = self.self_modulate
	preview.modulate.a = 0.6
	preview.size = self.size
	preview.position = -at_position

	pivot.add_child(preview)
	set_drag_preview(pivot)

	return self


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.is_in_group("todo_item")


func _drop_data(at_position: Vector2, data: Variant) -> void:
	# FIXME: avoid asumptions about the parent's of this node
	get_node("../../..")._drop_data(position - Vector2.ONE, data)


func save_to_disk(file : FileAccess) -> void:
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
