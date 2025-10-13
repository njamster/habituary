class_name BetterSpinBox
extends SpinBox


@export var format_string : String = "%s"
@export var numerical_input_only := true


@onready var line_edit := get_line_edit()


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
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


func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if numerical_input_only:
			var allowed_keys := (
				range(KEY_0, KEY_9 + 1) + range(KEY_KP_0, KEY_KP_9 + 1)
			)
			if not format_string.ends_with("d"):
				allowed_keys.append_array([KEY_COMMA, KEY_PERIOD])

			if event.shift_pressed or (
				not event.keycode in allowed_keys
				and not event.ctrl_pressed
			):
				if (
					event.is_action("ui_filedialog_show_hidden")
					or not Utils.is_built_in_action(event, false)
				):
					accept_event()

		if event.ctrl_pressed and not event.keycode in [
			KEY_A,
			KEY_C,
			KEY_X,
			KEY_V,
			KEY_Z,
		] or event.alt_pressed or event.meta_pressed:
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
	# 3) Apply those changes to the LineEdit node
	line_edit.text = new_text

	# Restore the original caret position
	line_edit.caret_column = caret_column
