extends VBoxContainer


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


func _setup_initial_state() -> void:
	_on_main_panel_changed()


func _connect_signals() -> void:
	#region Global Signals
	Settings.main_panel_changed.connect(_on_main_panel_changed)
	#endregion


func _on_main_panel_changed() -> void:
	visible = (Settings.main_panel != Settings.MainPanelState.CAPTURE_REVIEW)
