extends PanelContainer


func _init() -> void:
	self_modulate = Color(
		randf_range(0.3, 0.7),
		randf_range(0.3, 0.7),
		randf_range(0.3, 0.7)
	)


func _ready() -> void:
	%Edit.hide()
	%CheckBox.hide()
	%Label.show()


func edit() -> void:
	%Label.hide()
	%CheckBox.hide()
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		if event.pressed and event.double_click:
			edit()


func _get_drag_data(at_position: Vector2) -> Variant:
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


func _on_draw() -> void:
	# reposition the checkbox
	%CheckBox.global_position = global_position + Vector2(
		-1 * (%CheckBox.size.x + 8),
		0.5 * (size.y - %CheckBox.size.y)
	)


func _on_mouse_entered() -> void:
	$FocusTimer.stop()
	if not %Edit.visible:
		%CheckBox.show()


func _on_mouse_exited() -> void:
	$FocusTimer.start()


func _on_check_box_mouse_entered() -> void:
	$FocusTimer.stop()


func _on_check_box_mouse_exited() -> void:
	$FocusTimer.start()


func _on_focus_timer_timeout() -> void:
	%CheckBox.hide()


func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%Label.text = "[s]" + %Label.text + "[/s]"
		$Label.self_modulate.a = 0.5
	else:
		$Label.text = $Label.text.replace("[s]", "").replace("[/s]", "")
		$Label.self_modulate.a = 1.0
