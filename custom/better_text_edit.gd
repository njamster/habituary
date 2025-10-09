class_name BetterTextEdit
extends TextEdit


@export var all_in_one_line := false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.ctrl_pressed and not event.keycode in [
			KEY_A,
			KEY_C,
			KEY_X,
			KEY_V,
			KEY_Z,
		] or event.alt_pressed or event.meta_pressed:
			accept_event()


func _paste(_caret_index: int) -> void:
	if not editable:
		return  # early

	var clipboard := DisplayServer.clipboard_get()
	if clipboard.is_empty():
		return  # early

	if has_selection():
		delete_selection()

	if all_in_one_line:
		insert_text(clipboard.strip_escapes(), 0, get_caret_column())
	else:
		insert_text(clipboard, get_caret_line(), get_caret_column())


func _paste_primary_clipboard(caret_index: int) -> void:
	_paste(caret_index)
