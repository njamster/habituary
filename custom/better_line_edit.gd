class_name BetterLineEdit
extends LineEdit


@export var ignore_modifier_inputs := true

var allowed_keycodes := []


func _unhandled_key_input(event: InputEvent) -> void:
	if ignore_modifier_inputs or allowed_keycodes:
		if (
			event.is_pressed()
			and has_focus()
			and editable
			and OS.is_keycode_unicode(event.keycode)
		):
			if ignore_modifier_inputs:
				Log.debug(
					"Ignored modifier input: %s" % event.as_text_keycode()
				)
				accept_event()
			elif event.keycode not in allowed_keycodes:
				Log.debug(
					"Ignored non-numerical input: %s" % event.as_text_keycode()
				)
				accept_event()
