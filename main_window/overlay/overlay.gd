extends CanvasLayer

var _previous_min_size := Vector2i.ZERO


func _ready() -> void:
	close_overlay()

	EventBus.calendar_button_pressed.connect(open_component.bind($CalendarWidget, false))
	EventBus.settings_button_pressed.connect(open_component.bind($SettingsPanel, true))


func open_component(component : Node, dimmed_background : bool) -> void:
	$Background.color.a = 0.7 if dimmed_background else 0.0

	self.show()
	component.show()

	_previous_min_size = DisplayServer.window_get_min_size()
	DisplayServer.window_set_min_size(Vector2i(
		max(component.size.x, _previous_min_size.x),
		max(component.size.y, _previous_min_size.y)
	))


func close_overlay() -> void:
	self.hide()
	$CalendarWidget.hide()
	$SettingsPanel.hide()

	# FIXME: re-triggering the min_size calculation of the MainWindow would probably be cleaner
	DisplayServer.window_set_min_size(_previous_min_size)
	_previous_min_size = Vector2i.ZERO


func _on_dimmed_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		close_overlay()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_overlay()
