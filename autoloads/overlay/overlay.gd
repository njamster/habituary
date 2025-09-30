extends CanvasLayer


signal calendar_widget_closed


const TOAST := preload("toast/toast.tscn")


var calendar_button  # set in navigation_bar_right.gd


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


func _setup_initial_state() -> void:
	$CalendarWidget.hide()

	_on_side_panel_changed()


func _connect_signals() -> void:
	#region Global Signals
	Settings.side_panel_changed.connect(_on_side_panel_changed)
	#endregion

	#region Local Signals
	$CalendarWidget.visibility_changed.connect(func():
		if $CalendarWidget.visible:
			Utils.release_focus()
		else:
			calendar_widget_closed.emit()
	)
	$CalendarWidget.day_button_pressed.connect(func(date):
		Settings.current_day = date
		$CalendarWidget.hide()
	)
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


func toggle_calendar_widget_visibility():
	$CalendarWidget.visible = not $CalendarWidget.visible


func _input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("left_mouse_button")
		and not Utils.is_mouse_cursor_above($CalendarWidget)
		and not Utils.is_mouse_cursor_above(calendar_button)
	):
		$CalendarWidget.hide()


func _shortcut_input(event: InputEvent) -> void:
	if not event.is_action("toggle_calendar_widget"):
		$CalendarWidget.hide()
