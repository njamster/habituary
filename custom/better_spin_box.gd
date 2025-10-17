class_name BetterSpinBox
extends SpinBox


@export var format_string : String = "%s"
@export var numerical_input_only := true
@export var ignore_modifier_inputs := true

var allowed_keycodes := []

@onready var line_edit := get_line_edit()


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	if numerical_input_only:
		allowed_keycodes = (
			range(KEY_0, KEY_9 + 1) + range(KEY_KP_0, KEY_KP_9 + 1)
		)
		if not format_string.ends_with("d"):
			allowed_keycodes.append_array([KEY_COMMA, KEY_PERIOD])

	line_edit.set_script(preload("res://custom/better_line_edit.gd"))
	line_edit.ignore_modifier_inputs = ignore_modifier_inputs
	line_edit.allowed_keycodes = allowed_keycodes

	_update_max_length()
	_format_value()


func _connect_signals() -> void:
	#region Local Signals
	self.value_changed.connect(_format_value.unbind(1), CONNECT_DEFERRED)

	line_edit.focus_entered.connect(_format_value, CONNECT_DEFERRED)
	line_edit.text_submitted.connect(_format_value.unbind(1), CONNECT_DEFERRED)
	line_edit.focus_exited.connect(_format_value, CONNECT_DEFERRED)

	line_edit.gui_input.connect(_on_line_edit_gui_input)

	# Honestly, feels like this should be the built-in default behavior?!
	line_edit.text_submitted.connect(func(_new_text):
		if focus_mode == FOCUS_NONE:
			line_edit.release_focus()
	)

	if numerical_input_only:
		line_edit.text_changed.connect(_on_line_edit_text_changed)
	#endregion


func _format_value() -> void:
	line_edit.set_deferred("text", prefix + (format_string % value) + suffix)


func _update_max_length() -> void:
	if min_value >= 0:
		line_edit.max_length = (format_string % max_value).length()
	else:
		# One character for the (potential) minus sign, plus whatever value is
		# longer when formatted with the format_string: max_value or min_value
		line_edit.max_length = 1 + max(
			(format_string % abs(min_value)).length(),
			(format_string % abs(max_value)).length()
		)


func _on_line_edit_gui_input(event: InputEvent) -> void:
	if numerical_input_only:
		if event is InputEventKey and event.is_pressed():
			if OS.is_keycode_unicode(event.keycode):
				if event.shift_pressed or event.keycode not in allowed_keycodes:
					if not event.ctrl_pressed and not event.alt_pressed:
						if event.keycode not in [KEY_MINUS, KEY_KP_SUBTRACT]:
							Log.debug(
								"Ignored non-numerical input: %s"
								% event.as_text_keycode()
							)
							line_edit.reject_input(
								"Only numerical inputs allowed!"
							)
							accept_event()
						elif min_value >= 0:
							if (
								line_edit.caret_column == 0
								or line_edit.is_all_text_selected()
							):
								line_edit.reject_input(
									"No negative inputs allowed!"
								)
							accept_event()

	# Honestly, feels like this should be the built-in default behavior?!
	if focus_mode == FOCUS_NONE and event.is_action_pressed("ui_cancel"):
		line_edit.release_focus()

	if (
		event.is_action_pressed("middle_mouse_button")
		or event.is_action_pressed("right_mouse_button")
	):
		accept_event()


func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return  # early

	# Setting the LineEdit's text will reset the caret position.
	# So we have to save it here and manually restore it later!
	var caret_column := line_edit.caret_column

	# 1) Replace comma with period:
	new_text = new_text.replace(",", ".")
	# 2) Remove any but the first period sign:
	var first_period_position := new_text.find(".")
	new_text = new_text.replace(".", "")
	new_text = new_text.insert(first_period_position, ".")
	# 3) Remove any minus sign except it's in the front:
	var first_minus_position := new_text.find("-")
	new_text = new_text.replace("-", "")
	if first_minus_position == 0:
		new_text = new_text.insert(first_minus_position, "-")

	if float(new_text) < min_value:
		# New value would be too small -> autocorrect to min_value
		line_edit.text = format_string % min_value
		line_edit.select_all()
		line_edit.reject_input("Minimum required value: " + format_string % min_value)
	elif float(new_text) > max_value:
		# New value would be too large -> autocorrect to max_value
		line_edit.text = format_string % max_value
		line_edit.select_all()
		line_edit.reject_input("Maximum allowed value: " + format_string % max_value)
	else:
		# Apply new value & restore caret position
		line_edit.text = new_text
		line_edit.caret_column = caret_column


func _set(property: StringName, property_value: Variant) -> bool:
	if property == "max_value":
		max_value = property_value
		_update_max_length()
		return true  # property got handled here

	return false  # handle the property normally
