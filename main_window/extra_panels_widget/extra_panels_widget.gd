extends VBoxContainer


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	EventBus.side_panel_changed.connect(_on_side_panel_changed)
	_on_side_panel_changed()

	EventBus.bookmarks_due_today_changed.connect(_update_today_count)
	_update_today_count()

	EventBus.dark_mode_changed.connect(_on_dark_mode_changed)
	_on_dark_mode_changed(Settings.dark_mode)
	#endregion

	#region Local Signals
	$Capture.toggled.connect(_on_capture_toggled)

	$Bookmarks.toggled.connect(_on_bookmarks_toggled)
	$Bookmarks.mouse_entered.connect(_on_bookmarks_mouse_entered)
	$Bookmarks.mouse_exited.connect(_on_bookmarks_mouse_exited)

	$Help.toggled.connect(_on_help_toggled)
	#endregion


func _on_dark_mode_changed(dark_mode) -> void:
		if dark_mode:
			%TodayCount.add_theme_color_override("font_color", Settings.NORD_00)
		else:
			%TodayCount.add_theme_color_override("font_color", Settings.NORD_06)


func _update_today_count() -> void:
	%TodayCount.text = str(min(Settings.bookmarks_due_today, 9))
	%TodayCount.visible = (Settings.bookmarks_due_today != 0)
	%NotificationDot.visible = (Settings.bookmarks_due_today != 0)


func _on_side_panel_changed() -> void:
	match Settings.side_panel:
		Settings.SidePanelState.HIDDEN, Settings.SidePanelState.SETTINGS:
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


func _on_bookmarks_mouse_entered() -> void:
	if not Settings.dark_mode:
		%TodayCount.add_theme_color_override("font_color", Settings.NORD_00)


func _on_bookmarks_mouse_exited() -> void:
	if not Settings.dark_mode:
		%TodayCount.add_theme_color_override("font_color", Settings.NORD_06)
