extends PanelContainer


var SETTINGS := preload("settings/settings.tscn").instantiate()
var CAPTURE := preload("capture/capture.tscn").instantiate()
var BOOKMARKS := preload("bookmarks/bookmarks.tscn").instantiate()
var HELP := preload("help/help.tscn").instantiate()


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	custom_minimum_size.x = Settings.side_panel_width

	# FIXME: Slightly hacky way to make sure _search_for_bookmarks is run...
	add_child(BOOKMARKS)

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

	visible = (Settings.side_panel != Settings.SidePanelState.HIDDEN)

	if get_child_count():
		remove_child(get_child(0))

	if visible:
		match Settings.side_panel:
			Settings.SidePanelState.SETTINGS:
				add_child(SETTINGS)
			Settings.SidePanelState.CAPTURE:
				add_child(CAPTURE)
			Settings.SidePanelState.BOOKMARKS:
				add_child(BOOKMARKS)
			Settings.SidePanelState.HELP:
				add_child(HELP)
