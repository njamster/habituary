extends HBoxContainer

@export var text := "":
	set(value):
		var old_value = text
		text = value
		if is_inside_tree():
			%ToDo.text = text
			if old_value != value:
				SaveTimer.start()

@export var done := false:
	set(value):
		var old_value = done
		done = value
		if is_inside_tree():
			$CheckBox.button_pressed = done
			if old_value != value:
				SaveTimer.start()

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
		self.done = not self.done


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
	self.text = new_text

	if new_text:
		previous_focus = null
		grab_focus()
	else:
		%Edit.release_focus()


func _on_edit_focus_exited() -> void:
	%Edit.hide()

	if previous_focus:
		previous_focus.grab_focus()
		previous_focus = null

	if self.text:
		%ToDo.show()
	else:
		queue_free()


func _on_edit_text_changed(_new_text: String) -> void:
	SaveTimer.start()
