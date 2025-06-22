extends TextEdit


func _paste(_caret_index: int) -> void:
	if not editable:
		return  # early

	var clipboard := DisplayServer.clipboard_get()
	if clipboard.is_empty():
		return  # early

	if has_selection():
		delete_selection()

	insert_text(clipboard.strip_escapes(), 0, get_caret_column())
