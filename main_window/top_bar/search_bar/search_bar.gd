extends PanelContainer

const MINIMUM_GLOBAL_SEARCH_QUERY_SIZE := 3


func _ready() -> void:
	_set_initial_state()
	_connect_signals()

	%ShortcutHint.text = InputMap.action_get_events("search_screen")[0].as_text().to_upper().replace("+", " + ")


func _set_initial_state() -> void:
	%GlobalSearchHint.hide()
	%CloseButton.hide()

	# Hacky, but the only way I found to "disable" the scroll bars:
	%SearchQuery.get_h_scroll_bar().mouse_filter = MOUSE_FILTER_IGNORE
	%SearchQuery.get_h_scroll_bar().modulate.a = 0.0
	%SearchQuery.get_v_scroll_bar().mouse_filter = MOUSE_FILTER_IGNORE
	%SearchQuery.get_v_scroll_bar().modulate.a = 0.0


func _connect_signals() -> void:
	#region Global Signals
	EventBus.global_search_requested.connect(func():
		if Settings.search_query:
			if %SearchQuery.text != Settings.search_query:
				%SearchQuery.grab_focus()
				%SearchQuery.text = Settings.search_query
				%SearchQuery.set_caret_column(%SearchQuery.text.length())
			%SearchQuery.draw_spaces = false
			%ShortcutHint.hide()
			%GlobalSearchHint.hide()
			%CloseButton.show()
	)
	#endregion
	#region Local Signals
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	%Icon.pressed.connect(_on_icon_pressed)

	%SearchQuery.text_changed.connect(_on_search_query_text_changed)
	%SearchQuery.focus_entered.connect(_on_search_query_focus_entered)
	%SearchQuery.focus_exited.connect(_on_search_query_focus_exited)
	%SearchQuery.gui_input.connect(_on_search_query_gui_input)

	%SearchQuery/DebounceTimer.timeout.connect(
		EventBus.global_search_requested.emit
	)

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
	if Utils.is_mouse_cursor_above(self):
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
			%SearchQuery/DebounceTimer.start()
		elif not %SearchQuery.text:
			Settings.main_panel = Settings.MainPanelState.LIST_VIEW
	else:
		%GlobalSearchHint.visible = (
			%SearchQuery.text.length() >= MINIMUM_GLOBAL_SEARCH_QUERY_SIZE
		)
		# Re-set the caret column one frame later (to make sure it remains
		# visible, even after the GlobalSearchHint took up some space that
		# before that point still belonged to the SearchQuery).
		%SearchQuery.set_caret_column.call_deferred(
			%SearchQuery.get_caret_column()
		)

	# Do *not* draw spaces while the placeholder text is shown
	%SearchQuery.draw_spaces = (%SearchQuery.text != "")


func _on_search_query_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index in [
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_RIGHT,
		MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT
	]:
		# ignore scroll wheel inputs
		accept_event()
		return  # early

	if event is InputEventKey and event.is_pressed():
		# prevent the built-in TextEdit-behavior when pressing TAB...
		if event.keycode == KEY_TAB:
			accept_event()
			return
		# ... or ENTER (a.k.a. ui_accept)
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			if event.shift_pressed and \
				%SearchQuery.text.length() >= MINIMUM_GLOBAL_SEARCH_QUERY_SIZE:
					EventBus.global_search_requested.emit()
			else:
				%SearchQuery.release_focus()

			accept_event()
			return

	if event.is_action_pressed("ui_cancel"):
		clear_search_query()


func _on_mouse_entered() -> void:
	if get_viewport().gui_get_focus_owner() != %SearchQuery:
		self.theme_type_variation = "SearchBar_Hover"


func _on_mouse_exited() -> void:
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
