extends Button
class_name ToggleButton

@export var icon_toggled_off : Texture2D
@export var icon_toggled_on : Texture2D


func _ready() -> void:
	toggle_mode = true

	self.toggled.connect(_on_toggled)
	_on_toggled(button_pressed)


func _on_toggled(toggled_on : bool) -> void:
	if toggled_on:
		self.icon = icon_toggled_on
	else:
		self.icon = icon_toggled_off
