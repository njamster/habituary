class_name BetterTextEdit
extends TextEdit


@export var all_in_one_line := false
@export var ignore_modifier_inputs := true


func _unhandled_key_input(event: InputEvent) -> void:
	if ignore_modifier_inputs:
		if (
			event.is_pressed()
			and has_focus()
			and editable
			and OS.is_keycode_unicode(event.keycode)
		):
			Log.debug("Ignored modifier input: %s" % event.as_text_keycode())
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
	if not has_focus():
		grab_focus()

	_paste(caret_index)
