@tool
extends Button
class_name ToggleButton


@export var icon_toggled_off: Texture2D:
	set(value):
		icon_toggled_off = value
		_on_toggled()

@export var icon_toggled_on: Texture2D:
	set(value):
		icon_toggled_on = value
		_on_toggled()


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	toggle_mode = true
	_on_toggled()


func _connect_signals() -> void:
	toggled.connect(_on_toggled)


func _on_toggled(toggled_on := button_pressed) -> void:
	icon = icon_toggled_on if toggled_on else icon_toggled_off


func _set(property: StringName, _value: Variant) -> bool:
	if property == "toggle_mode" or property == "icon":
		# the user is not supposed to change these properties directly
		return true

	return false
