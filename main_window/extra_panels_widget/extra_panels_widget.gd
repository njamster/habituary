extends VBoxContainer


func _on_settings_pressed() -> void:
	EventBus.settings_button_pressed.emit()
