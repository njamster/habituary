extends HBoxContainer

const TRIGGER_ZONE_WIDTH := 44  # pixels


func _ready() -> void:
	deactivate()

	EventBus.side_panel_changed.connect(_on_side_panel_changed)


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
	if Settings.side_panel == Settings.SidePanelState.HIDDEN:
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
