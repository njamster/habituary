extends PanelContainer


var _contains_mouse_cursor := false


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
	%SearchQuery.select_all()
	%ShortcutHint.hide()


func _on_search_query_focus_exited() -> void:
	if _contains_mouse_cursor:
		theme_type_variation = "SearchBar_Hover"
	else:
		theme_type_variation = "SearchBar"
	%ShortcutHint.show()


func _on_search_query_text_changed() -> void:
	Settings.search_query = %SearchQuery.text

	# Do *not* draw spaces while the placeholder text is shown
	%SearchQuery.draw_spaces = (%SearchQuery.text != "")


func _on_search_query_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		# prevent the built-in TextEdit-behavior when pressing TAB...
		if event.keycode == KEY_TAB:
			accept_event()
			return
		# ... or ENTER (a.k.a. ui_accept)
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			%SearchQuery.release_focus()
			accept_event()
			return

	if event.is_action_pressed("ui_cancel"):
		%SearchQuery.text = ""
		%SearchQuery.text_changed.emit()
		%SearchQuery.release_focus()


func _on_shortcut_hint_pressed() -> void:
	%SearchQuery.grab_focus()


func _on_mouse_entered() -> void:
	_contains_mouse_cursor = true

	if get_viewport().gui_get_focus_owner() != %SearchQuery:
		self.theme_type_variation = "SearchBar_Hover"


func _on_mouse_exited() -> void:
	_contains_mouse_cursor = false

	if get_viewport().gui_get_focus_owner() != %SearchQuery:
		self.theme_type_variation = "SearchBar"


func _on_icon_pressed() -> void:
	%SearchQuery.grab_focus()
