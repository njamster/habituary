extends MarginContainer

const DIMMED_ALPHA := 0.7


func _ready() -> void:
	for component in [%CalendarWidget]:
		component.hide()
	self.hide()

	EventBus.calendar_button_pressed.connect(
		func():
			if not %CalendarWidget.visible:
				open_component(%CalendarWidget, false)
			else:
				close_overlay()
	)

	EventBus.todo_list_clicked.connect(close_overlay)


func open_component(component : Control, dimmed_background : bool) -> void:
	if dimmed_background:
		$Background.mouse_filter = Control.MOUSE_FILTER_STOP
		$Background.color.a = DIMMED_ALPHA
	else:
		$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Background.color.a = 0.0

	if component.visible:
		return

	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner:
		focus_owner.release_focus()

	self.show()
	for c in [%CalendarWidget]:
		c.hide()
	component.show()


func close_overlay() -> void:
	if not self.visible:
		return

	for component in [%CalendarWidget]:
		component.hide()
	self.hide()

	EventBus.overlay_closed.emit()


func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# left-click anywhere on the background to close the currently visible overlay
		close_overlay()


func _shortcut_input(event: InputEvent) -> void:
	if self.visible:
		if event.is_action_pressed("ui_cancel"):
			# press escape to close the currently visible overlay
			close_overlay()
		elif $Background.color.a != 0.0:
			# consume any InputEventKey or InputEventShortcut event here to stop it from propagating
			# further up in the tree (i.e. beyond the scope of this overlay)
			get_viewport().set_input_as_handled()


func _unhandled_input(_event: InputEvent) -> void:
	if self.visible and $Background.color.a != 0.0:
		# consume any remaining unhandled input events here to stop it from propagating further up
		# in the tree (i.e. beyond the scope of this overlay)
		get_viewport().set_input_as_handled()
