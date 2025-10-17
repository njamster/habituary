class_name BetterLineEdit
extends LineEdit


@export var ignore_modifier_inputs := true

var allowed_keycodes := []

var rejection_tween: Tween


func _init() -> void:
	_connect_signals()


func _connect_signals() -> void:
	text_change_rejected.connect(func(_rejected_text):
		reject_input("Maximum length reached")
	)


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
				reject_input("Only numerical inputs allowed!")
				accept_event()


func reject_input(reason := "") -> void:
	var style_box := get_theme_stylebox("focus")

	if rejection_tween:
		rejection_tween.kill()
		style_box.border_color = get_meta("original_border_color")
	rejection_tween = create_tween()
	set_meta("original_border_color", style_box.border_color)

	rejection_tween.tween_property(
		style_box,
		"border_color",
		Color.RED,
		0.1
	)
	rejection_tween.tween_property(
		style_box,
		"border_color",
		style_box.border_color,
		0.3
	)

	if reason:
		Overlay.spawn_toast(reason)


func is_all_text_selected() -> bool:
	return (
		has_selection()
		and get_selection_from_column() == 0
		and get_selection_to_column() == text.length()
	)
