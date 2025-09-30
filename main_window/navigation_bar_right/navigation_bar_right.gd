extends VBoxContainer


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


func _setup_initial_state() -> void:
	Overlay.calendar_button = $Calendar


func _connect_signals() -> void:
	#region Global Signals
	Settings.view_mode_changed.connect(_on_view_mode_changed)

	Overlay.calendar_widget_closed.connect(_on_calendar_widget_closed)

	Settings.main_panel_changed.connect(func():
		$NextDay.visible = (
			Settings.main_panel == Settings.MainPanelState.LIST_VIEW
		)
		$ShiftViewForward.visible = (
			Settings.main_panel == Settings.MainPanelState.LIST_VIEW
		)
		$Spacer.visible = (
			Settings.main_panel == Settings.MainPanelState.LIST_VIEW
		)
	)
	#endregion

	#region Local Signals
	$NextDay.pressed.connect(_on_next_day_pressed)

	$ShiftViewForward.pressed.connect(_on_shift_view_forward_pressed)

	$Calendar.toggled.connect(_on_calendar_toggled)
	#endregion


func _on_next_day_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(1)


func _on_shift_view_forward_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(Settings.view_mode)


func _on_view_mode_changed() -> void:
	if Settings.view_mode == 1:
		$ShiftViewForward/Tooltip.text = "Move %d Day Forward" % Settings.view_mode
	else:
		$ShiftViewForward/Tooltip.text = "Move %d Days Forward" % Settings.view_mode


func _on_calendar_toggled(toggled_on: bool) -> void:
	Overlay.toggle_calendar_widget_visibility()

	if toggled_on:
		$Calendar/Tooltip.disabled = true
	else:
		$Calendar/Tooltip.disabled = false


func _on_calendar_widget_closed() -> void:
	if $Calendar.button_pressed:
		$Calendar.set_pressed_no_signal(false)
		$Calendar/Tooltip.disabled = false
