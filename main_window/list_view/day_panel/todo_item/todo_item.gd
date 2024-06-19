extends MarginContainer


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
