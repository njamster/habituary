extends PanelContainer

@export var done := false:
	set(value):
		done = value
		if is_inside_tree():
			if done:
				modulate.a = 0.3
			else:
				modulate.a = 1.0


func _init() -> void:
	self_modulate = Color(
		randf_range(0.3, 0.7),
		randf_range(0.3, 0.7),
		randf_range(0.3, 0.7)
	)


func _ready() -> void:
	%Edit.hide()
	%Label.show()


func edit() -> void:
	%Label.hide()
	%Edit.show()
	%Edit.grab_focus()


func _on_edit_text_submitted(new_text: String) -> void:
	%Label.text = new_text
	%Edit.hide()
	%Label.show()


func _on_edit_focus_exited() -> void:
	if %Edit.text:
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
				if event.pressed and not %Edit.visible:
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
