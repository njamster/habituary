extends VBoxContainer


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	Settings.view_mode_changed.connect(_on_view_mode_changed)

	EventBus.overlay_closed.connect(_on_overlay_closed)
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
	EventBus.calendar_button_pressed.emit()

	if toggled_on:
		$Calendar/Tooltip.disabled = true
	else:
		$Calendar/Tooltip.disabled = false


func _on_overlay_closed() -> void:
	if $Calendar.button_pressed:
		$Calendar.set_pressed_no_signal(false)
		$Calendar/Tooltip.disabled = false
