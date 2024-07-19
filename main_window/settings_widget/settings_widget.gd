extends VBoxContainer


func _ready() -> void:
	_on_dark_mode_changed(Settings.dark_mode)

	EventBus.dark_mode_changed.connect(_on_dark_mode_changed)


func _on_mode_pressed() -> void:
	Settings.dark_mode = not Settings.dark_mode


func _on_dark_mode_changed(dark_mode) -> void:
	if dark_mode:
		$Mode.icon = preload("images/mode_light.svg")
		$Mode/Tooltip.text = "Switch To Light Mode"
	else:
		$Mode.icon = preload("images/mode_dark.svg")
		$Mode/Tooltip.text = "Switch To Dark Mode"


func _on_settings_pressed() -> void:
	EventBus.settings_button_pressed.emit()
