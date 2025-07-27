extends CanvasLayer

const TOAST := preload("toast/toast.tscn")


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


func _setup_initial_state() -> void:
	_on_side_panel_changed()


func _connect_signals() -> void:
	#region Global Signals
	Settings.side_panel_changed.connect(_on_side_panel_changed)
	#endregion


func _on_side_panel_changed() -> void:
	if Settings.side_panel == Settings.SidePanelState.HIDDEN:
		$OuterMargin.add_theme_constant_override("margin_left", 16)
	else:
		$OuterMargin.add_theme_constant_override(
			"margin_left",
			Settings.side_panel_width + 16
		)


func spawn_toast(text : String) -> void:
	var toast := TOAST.instantiate()
	%Toasts.add_child(toast)

	toast.text = text
	toast.fade_out_and_close()
