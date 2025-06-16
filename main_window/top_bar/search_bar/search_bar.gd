extends PanelContainer

const MINIMUM_GLOBAL_SEARCH_QUERY_SIZE := 3

var _contains_mouse_cursor := false


func _ready() -> void:
	_set_initial_state()
	_connect_signals()

	%ShortcutHint.text = InputMap.action_get_events("search_screen")[0].as_text().to_upper().replace("+", " + ")


func _set_initial_state() -> void:
	%GlobalSearchHint.hide()
	%CloseButton.hide()


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

	%CloseButton.pressed.connect(clear_search_query)
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
	if Settings.main_panel != Settings.MainPanelState.GLOBAL_SEARCH:
		%GlobalSearchHint.visible = (
			%SearchQuery.text.length() >= MINIMUM_GLOBAL_SEARCH_QUERY_SIZE
		)
	%CloseButton.visible = ($%SearchQuery.text != "")
	%SearchQuery.select_all()
	%ShortcutHint.hide()


func _on_search_query_focus_exited() -> void:
	if _contains_mouse_cursor:
		theme_type_variation = "SearchBar_Hover"
	else:
		theme_type_variation = "SearchBar"
	%GlobalSearchHint.hide()
	%CloseButton.hide()
	%ShortcutHint.show()


func _on_search_query_text_changed() -> void:
	Settings.search_query = %SearchQuery.text

	%CloseButton.visible = ($%SearchQuery.text != "")

	if Settings.main_panel == Settings.MainPanelState.GLOBAL_SEARCH:
		if %SearchQuery.text.length() >= MINIMUM_GLOBAL_SEARCH_QUERY_SIZE:
			EventBus.global_search_requested.emit()
		elif not %SearchQuery.text:
			Settings.main_panel = Settings.MainPanelState.LIST_VIEW
	else:
		%GlobalSearchHint.visible = (
			%SearchQuery.text.length() >= MINIMUM_GLOBAL_SEARCH_QUERY_SIZE
		)

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
			if event.shift_pressed and \
				%SearchQuery.text.length() >= MINIMUM_GLOBAL_SEARCH_QUERY_SIZE:
					EventBus.global_search_requested.emit()
					%GlobalSearchHint.hide()
			else:
				%SearchQuery.release_focus()

			accept_event()
			return

	if event.is_action_pressed("ui_cancel"):
		clear_search_query()


func _on_mouse_entered() -> void:
	_contains_mouse_cursor = true

	if get_viewport().gui_get_focus_owner() != %SearchQuery:
		self.theme_type_variation = "SearchBar_Hover"


func _on_mouse_exited() -> void:
	_contains_mouse_cursor = false

	if get_viewport().gui_get_focus_owner() != %SearchQuery:
		self.theme_type_variation = "SearchBar"


func _on_icon_pressed() -> void:
	if %SearchQuery.has_focus():
		%SearchQuery.select_all()
	else:
		%SearchQuery.grab_focus()


func clear_search_query() -> void:
	%SearchQuery.text = ""
	%SearchQuery.text_changed.emit()
	%SearchQuery.release_focus()
