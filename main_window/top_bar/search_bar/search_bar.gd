extends PanelContainer


func _ready() -> void:
	_connect_signals()

	%ShortcutHint.text = InputMap.action_get_events("search_screen")[0].as_text().to_upper().replace("+", " + ")


func _connect_signals() -> void:
	#region Local Signals
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	%Icon.pressed.connect(_on_icon_pressed)

	%SearchQuery.text_changed.connect(_on_search_query_text_changed)
	%SearchQuery.text_submitted.connect(_on_search_query_text_submitted)
	%SearchQuery.focus_entered.connect(_on_search_query_focus_entered)
	%SearchQuery.focus_exited.connect(_on_search_query_focus_exited)
	%SearchQuery.gui_input.connect(_on_search_query_gui_input)

	%ShortcutHint.pressed.connect(_on_shortcut_hint_pressed)
	#endregion


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("search_screen"):
		%SearchQuery.grab_focus()
		accept_event()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		%SearchQuery.grab_focus()
		accept_event()


func _on_search_query_focus_entered() -> void:
	theme_type_variation = "SearchBar_Focused"
	%ShortcutHint.hide()


func _on_search_query_focus_exited() -> void:
	theme_type_variation = "SearchBar"
	%ShortcutHint.show()


func _on_search_query_text_changed(new_text: String) -> void:
	Settings.search_query = new_text


func _on_search_query_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		%SearchQuery.text = ""
		%SearchQuery.text_changed.emit("")


func _on_search_query_text_submitted(_new_text: String) -> void:
	%SearchQuery.release_focus()


func _on_shortcut_hint_pressed() -> void:
	%SearchQuery.grab_focus()


func _on_mouse_entered() -> void:
	if get_viewport().gui_get_focus_owner() != %SearchQuery:
		self.theme_type_variation = "SearchBar_Hover"


func _on_mouse_exited() -> void:
	if get_viewport().gui_get_focus_owner() != %SearchQuery:
		self.theme_type_variation = "SearchBar"


func _on_icon_pressed() -> void:
	%SearchQuery.grab_focus()
