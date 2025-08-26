extends PanelContainer


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	custom_minimum_size.x = Settings.side_panel_width

	_update_side_panel()


func _connect_signals() -> void:
	#region Global Signals
	Settings.main_panel_changed.connect(_update_side_panel)
	Settings.side_panel_changed.connect(_update_side_panel)
	#endregion


func _update_side_panel() -> void:
	if Settings.main_panel == Settings.MainPanelState.CAPTURE_REVIEW:
		hide()
		return  # early

	$Settings.visible = (
		Settings.side_panel == Settings.SidePanelState.SETTINGS
	)
	$SavedSearches.visible = (
		Settings.side_panel == Settings.SidePanelState.SAVED_SEARCHES
	)
	$Capture.visible = (
		Settings.side_panel == Settings.SidePanelState.CAPTURE
	)
	$Bookmarks.visible = (
		Settings.side_panel == Settings.SidePanelState.BOOKMARKS
	)
	$Help.visible = (
		Settings.side_panel == Settings.SidePanelState.HELP
	)

	visible = (Settings.side_panel != Settings.SidePanelState.HIDDEN)
