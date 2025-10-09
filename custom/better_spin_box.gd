class_name BetterSpinBox
extends SpinBox


@export var format_string : String = "%s"


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
	#endregion


func _format_value() -> void:
	line_edit.set_deferred("text", prefix + (format_string % value) + suffix)


func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.ctrl_pressed and not event.keycode in [
			KEY_A,
			KEY_C,
			KEY_X,
			KEY_V,
			KEY_Z,
		] or event.alt_pressed or event.meta_pressed:
			accept_event()
