extends VBoxContainer


func _on_capture_toggled(toggled_on: bool) -> void:
	if not($Bookmarks.button_pressed or $Help.button_pressed):
		$Capture/Tooltip.hide_tooltip()

	if toggled_on:
		$Capture/Tooltip.text = $Capture/Tooltip.text.replace("Show", "Hide")
		$Bookmarks.button_pressed = false
		$Help.button_pressed = false
	else:
		$Capture/Tooltip.text = $Capture/Tooltip.text.replace("Hide", "Show")

	EventBus.capture_button_pressed.emit()


func _on_bookmarks_toggled(toggled_on: bool) -> void:
	if not($Capture.button_pressed or $Help.button_pressed):
		$Bookmarks/Tooltip.hide_tooltip()

	if toggled_on:
		$Capture.button_pressed = false
		$Bookmarks/Tooltip.text = $Bookmarks/Tooltip.text.replace("Show", "Hide")
		$Help.button_pressed = false
	else:
		$Bookmarks/Tooltip.text = $Bookmarks/Tooltip.text.replace("Hide", "Show")

	EventBus.bookmarks_button_pressed.emit()


func _on_help_toggled(toggled_on: bool) -> void:
	if not($Capture.button_pressed or $Bookmarks.button_pressed):
		$Help/Tooltip.hide_tooltip()

	if toggled_on:
		$Capture.button_pressed = false
		$Bookmarks.button_pressed = false
		$Help/Tooltip.text = $Help/Tooltip.text.replace("Show", "Hide")
	else:
		$Help/Tooltip.text = $Help/Tooltip.text.replace("Hide", "Show")

	EventBus.help_button_pressed.emit()
