extends SpinBox

@export var format_string : String = "%s"

@onready var line_edit := get_line_edit()


func _ready() -> void:
	self.value_changed.connect(_format_value.unbind(1), CONNECT_DEFERRED)

	line_edit.focus_entered.connect(_format_value, CONNECT_DEFERRED)
	line_edit.text_submitted.connect(_format_value.unbind(1), CONNECT_DEFERRED)
	line_edit.focus_exited.connect(_format_value, CONNECT_DEFERRED)

	_format_value()


func _format_value() -> void:
	line_edit.set_deferred("text", prefix + (format_string % value) + suffix)
