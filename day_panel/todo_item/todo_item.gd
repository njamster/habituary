extends HBoxContainer

@export var text := "":
	set(value):
		text = value
		if is_inside_tree():
			%ToDo.text = text

@export var done := false:
	set(value):
		done = value
		if is_inside_tree():
			$CheckBox.button_pressed = done

var previous_focus


func _ready() -> void:
	# trigger setters manually once
	text = text
	done = done

	_on_focus_exited() # poor man's focus highlight :D


func _on_focus_entered() -> void:
	modulate.a = 1.0 # poor man's focus highlight :D


func _on_focus_exited() -> void:
	modulate.a = 0.4 # poor man's focus highlight :D


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_item", false, true):
		$CheckBox.button_pressed = not $CheckBox.button_pressed


func edit(side := 0) -> void:
	%ToDo.hide()
	%Edit.text = %ToDo.text
	if side < 0:
		%Edit.caret_column = 0
	elif side > 0:
		%Edit.caret_column = %Edit.text.length()
	else:
		%Edit.select()
	%Edit.show()
	previous_focus = get_viewport().gui_get_focus_owner()
	%Edit.grab_focus()


func _on_edit_text_submitted(new_text: String) -> void:
	if new_text:
		text = new_text
		%Edit.hide()
		%ToDo.show()
		grab_focus()
	elif previous_focus != null and previous_focus != self:
		previous_focus.grab_focus()
		previous_focus = null
		queue_free()


func _on_edit_focus_exited() -> void:
	if text:
		_on_edit_text_submitted(text)
	elif previous_focus != null and previous_focus != self:
		previous_focus.grab_focus()
		previous_focus = null
		queue_free()
	else:
		queue_free()

