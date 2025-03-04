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

	_update_side_panel()


func _connect_signals() -> void:
	Settings.side_panel_changed.connect(_update_side_panel)


func _update_side_panel() -> void:
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
