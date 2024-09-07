extends VBoxContainer


func _on_capture_toggled(toggled_on: bool) -> void:
	if not($Alarms.button_pressed or $Help.button_pressed):
		$Capture/Tooltip.hide_tooltip()

	if toggled_on:
		$Capture/Tooltip.text = $Capture/Tooltip.text.replace("Show", "Hide")
		$Alarms.button_pressed = false
		$Help.button_pressed = false
	else:
		$Capture/Tooltip.text = $Capture/Tooltip.text.replace("Hide", "Show")

	EventBus.capture_button_pressed.emit()


func _on_alarms_toggled(toggled_on: bool) -> void:
	if not($Capture.button_pressed or $Help.button_pressed):
		$Alarms/Tooltip.hide_tooltip()

	if toggled_on:
		$Alarms/Tooltip.text = $Alarms/Tooltip.text.replace("Show", "Hide")
		$Capture.button_pressed = false
		$Help.button_pressed = false
	else:
		$Alarms/Tooltip.text = $Alarms/Tooltip.text.replace("Hide", "Show")

	EventBus.alarms_button_pressed.emit()


func _on_help_toggled(toggled_on: bool) -> void:
	if not($Capture.button_pressed or $Alarms.button_pressed):
		$Help/Tooltip.hide_tooltip()

	if toggled_on:
		$Help/Tooltip.text = $Help/Tooltip.text.replace("Show", "Hide")
		$Capture.button_pressed = false
		$Alarms.button_pressed = false
	else:
		$Help/Tooltip.text = $Help/Tooltip.text.replace("Hide", "Show")

	EventBus.help_button_pressed.emit()
