extends CanvasLayer

const TRANSPARENT_ALPHA := 0.0
const DIMMED_ALPHA := 0.7

var _previous_min_size := Vector2i.ZERO


func _ready() -> void:
	close_overlay()

	EventBus.calendar_button_pressed.connect(open_component.bind($CalendarWidget, false))
	EventBus.settings_button_pressed.connect(open_component.bind($SettingsPanel, true))


func open_component(component : Control, dimmed_background : bool) -> void:
	$Background.color.a = DIMMED_ALPHA if dimmed_background else TRANSPARENT_ALPHA

	self.show()
	component.show()

	_previous_min_size = DisplayServer.window_get_min_size()

	component.item_rect_changed.connect(_update_min_size.bind(component))
	_update_min_size(component)


func _update_min_size(component : Control) -> void:
	get_window().min_size = Vector2i(
		max(component.size.x + component.get_meta("x_padding", 0), _previous_min_size.x),
		max(component.size.y + component.get_meta("y_padding", 0), _previous_min_size.y)
	)


func close_overlay() -> void:
	for component in [$CalendarWidget, $SettingsPanel]:
		component.hide()
		if component.item_rect_changed.is_connected(_update_min_size):
			component.item_rect_changed.disconnect(_update_min_size)
	self.hide()

	# FIXME: re-triggering the min_size calculation of the MainWindow would probably be cleaner
	get_window().min_size = _previous_min_size
	_previous_min_size = Vector2i.ZERO


func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# left-click anywhere on the background to close the currently visible overlay
		close_overlay()


func _shortcut_input(event: InputEvent) -> void:
	if self.visible:
		if event.is_action_pressed("ui_cancel"):
			# press escape to close the currently visible overlay
			close_overlay()
		elif $Background.color.a != TRANSPARENT_ALPHA:
			# consume any InputEventKey or InputEventShortcut event here to stop it from propagating
			# further up in the tree (i.e. beyond the scope of this overlay)
			get_viewport().set_input_as_handled()


func _unhandled_input(_event: InputEvent) -> void:
	if self.visible and $Background.color.a != TRANSPARENT_ALPHA:
		# consume any remaining unhandled input events here to stop it from propagating further up
		# in the tree (i.e. beyond the scope of this overlay)
		get_viewport().set_input_as_handled()
