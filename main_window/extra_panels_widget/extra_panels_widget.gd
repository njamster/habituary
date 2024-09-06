extends VBoxContainer


func _on_capture_pressed() -> void:
	EventBus.capture_button_pressed.emit()


func _on_alarms_pressed() -> void:
	EventBus.alarms_button_pressed.emit()


func _on_help_pressed() -> void:
	EventBus.help_button_pressed.emit()
