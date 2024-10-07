extends VBoxContainer


func _ready() -> void:
	EventBus.side_panel_changed.connect(_on_side_panel_changed)


func _on_side_panel_changed() -> void:
	match Settings.side_panel:
		Settings.SidePanelState.HIDDEN:
			$Capture.set_pressed_no_signal(false)
			_update_tooltip($Capture)
			$Bookmarks.set_pressed_no_signal(false)
			_update_tooltip($Bookmarks)
			$Help.set_pressed_no_signal(false)
			_update_tooltip($Help)
		Settings.SidePanelState.CAPTURE:
			$Capture.set_pressed_no_signal(true)
			_update_tooltip($Capture)
			$Bookmarks.set_pressed_no_signal(false)
			_update_tooltip($Bookmarks)
			$Help.set_pressed_no_signal(false)
			_update_tooltip($Help)
		Settings.SidePanelState.BOOKMARKS:
			$Capture.set_pressed_no_signal(false)
			_update_tooltip($Capture)
			$Bookmarks.set_pressed_no_signal(true)
			_update_tooltip($Bookmarks)
			$Help.set_pressed_no_signal(false)
			_update_tooltip($Help)
		Settings.SidePanelState.HELP:
			$Capture.set_pressed_no_signal(false)
			_update_tooltip($Capture)
			$Bookmarks.set_pressed_no_signal(false)
			_update_tooltip($Bookmarks)
			$Help.set_pressed_no_signal(true)
			_update_tooltip($Help)


func _update_tooltip(node : Control) -> void:
	if node.button_pressed:
		node.get_node("Tooltip").text = node.get_node("Tooltip").text.replace("Show", "Hide")
	else:
		node.get_node("Tooltip").text = node.get_node("Tooltip").text.replace("Hide", "Show")


func _on_capture_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Settings.side_panel = Settings.SidePanelState.CAPTURE
	else:
		Settings.side_panel = Settings.SidePanelState.HIDDEN


func _on_bookmarks_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Settings.side_panel = Settings.SidePanelState.BOOKMARKS
	else:
		Settings.side_panel = Settings.SidePanelState.HIDDEN


func _on_help_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Settings.side_panel = Settings.SidePanelState.HELP
	else:
		Settings.side_panel = Settings.SidePanelState.HIDDEN
