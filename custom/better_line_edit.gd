class_name BetterLineEdit
extends LineEdit


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
