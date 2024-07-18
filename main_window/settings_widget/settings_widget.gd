extends VBoxContainer


func _ready() -> void:
	_on_dark_mode_changed(Settings.dark_mode)

	EventBus.dark_mode_changed.connect(_on_dark_mode_changed)


func _on_mode_pressed() -> void:
	Settings.dark_mode = not Settings.dark_mode


func _on_dark_mode_changed(dark_mode) -> void:
	$Mode.icon = preload("images/mode_light.svg") if dark_mode else preload("images/mode_dark.svg")


func _on_settings_pressed() -> void:
	EventBus.settings_button_pressed.emit()
