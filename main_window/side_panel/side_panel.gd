extends PanelContainer


func _ready() -> void:
	self.hide()

	for panel in [$Capture, $Bookmarks, $Help]:
		panel.hide()

	EventBus.capture_button_pressed.connect(_toggle_panel.bind($Capture))
	EventBus.bookmarks_button_pressed.connect(_toggle_panel.bind($Bookmarks))
	EventBus.help_button_pressed.connect(_toggle_panel.bind($Help))

	EventBus.view_mode_changed.connect(func(_view_mode): _calculate_minimum_width())
	get_viewport().size_changed.connect(_calculate_minimum_width)


func _toggle_panel(target : Control) -> void:
	for panel in [$Capture, $Bookmarks, $Help]:
		if panel == target:
			panel.visible = not panel.visible
			if panel.visible:
				self.show()
			else:
				self.hide()
		else:
			panel.hide()


func _on_visibility_changed() -> void:
	if self.visible:
		_calculate_minimum_width()


func _calculate_minimum_width() -> void:
	# FIXME: get rid of the hardcoded values
	custom_minimum_size.x = (get_window().size.x - 2 * 28 + 2 * 16) / float(Settings.view_mode + 1)
