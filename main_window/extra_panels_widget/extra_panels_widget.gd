extends VBoxContainer


func _ready() -> void:
	EventBus.overlay_closed.connect(func():
		$SearchScreen.set_pressed_no_signal(false)
	)


func _on_settings_pressed() -> void:
	EventBus.settings_button_pressed.emit()


func _on_search_screen_toggled(_toggled_on: bool) -> void:
	EventBus.search_screen_button_pressed.emit()
