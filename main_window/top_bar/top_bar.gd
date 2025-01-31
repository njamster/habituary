extends HBoxContainer


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	Settings.dark_mode_changed.connect(_on_dark_mode_changed)
	_on_dark_mode_changed()

	Settings.side_panel_changed.connect(_on_side_panel_changed)
	_on_side_panel_changed()
	#endregion

	#region Local Signals
	$Settings.toggled.connect(_on_settings_toggled)

	$Mode.pressed.connect(_on_mode_pressed)
	#endregion


func _on_side_panel_changed() -> void:
	if Settings.side_panel == Settings.SidePanelState.SETTINGS:
		$Settings.set_pressed_no_signal(true)
	else:
		$Settings.set_pressed_no_signal(false)

	if $Settings.button_pressed:
		$Settings.get_node("Tooltip").text = $Settings.get_node("Tooltip").text.replace("Show", "Hide")
	else:
		$Settings.get_node("Tooltip").text = $Settings.get_node("Tooltip").text.replace("Hide", "Show")


func _on_settings_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Settings.side_panel = Settings.SidePanelState.SETTINGS
	else:
		Settings.side_panel = Settings.SidePanelState.HIDDEN


func _on_mode_pressed() -> void:
	Settings.dark_mode = not Settings.dark_mode


func _on_dark_mode_changed() -> void:
	if Settings.dark_mode:
		$Mode.icon = preload("images/mode_light.svg")
		$Mode/Tooltip.text = "Switch To Light Mode"
	else:
		$Mode.icon = preload("images/mode_dark.svg")
		$Mode/Tooltip.text = "Switch To Dark Mode"
