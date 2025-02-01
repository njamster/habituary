extends HBoxContainer

const TRIGGER_ZONE_WIDTH := 44  # pixels


func _ready() -> void:
	_connect_signals()
	deactivate()


func _connect_signals() -> void:
	#region Global Signals
	Settings.side_panel_changed.connect(_on_side_panel_changed)
	_on_side_panel_changed()
	#endregion

	#region Local Signals
	$LeftBorder/DragHoverTrigger.triggered.connect(_on_left_border_drag_hover_trigger_triggered)

	$RightBorder/DragHoverTrigger.triggered.connect(_on_right_border_drag_hover_trigger_triggered)
	#endregion


func activate() -> void:
	show()
	set_process(true)


func deactivate() -> void:
	set_process(false)
	hide()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_BEGIN:
			if get_viewport().gui_get_drag_data() is Array:
				activate()
		NOTIFICATION_DRAG_END:
			deactivate()


func _on_side_panel_changed() -> void:
	if Settings.side_panel == Settings.SidePanelState.HIDDEN or \
		Settings.side_panel == Settings.SidePanelState.CAPTURE:
			$LeftBorder.add_theme_constant_override("margin_left", 0)
			$LeftBorder.size.x = 0 # shrink to minimum width again
	else:
		var side_panel_width = get_node("../HBox/SidePanel").custom_minimum_size.x
		$LeftBorder.add_theme_constant_override("margin_left", side_panel_width)


func _process(_delta: float) -> void:
	var window_size = get_window().size.x
	var left_padding = $LeftBorder["theme_override_constants/margin_left"]
	$LeftBorder.visible = (get_parent().get_global_mouse_position().x < left_padding + TRIGGER_ZONE_WIDTH)
	$RightBorder.visible = (get_parent().get_global_mouse_position().x > window_size - TRIGGER_ZONE_WIDTH)


func _on_left_border_drag_hover_trigger_triggered() -> void:
	Settings.current_day = Settings.current_day.add_days(-1)


func _on_right_border_drag_hover_trigger_triggered() -> void:
	Settings.current_day = Settings.current_day.add_days(+1)
