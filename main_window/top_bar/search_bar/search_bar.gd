extends PanelContainer


func _ready() -> void:
	EventBus.current_day_changed.connect(func(_current_day):
		EventBus.search_query_changed.emit.call_deferred()
	)
	EventBus.view_mode_changed.connect(func(_view_mode):
		EventBus.search_query_changed.emit.call_deferred()
	)

	EventBus.dark_mode_changed.connect(func(dark_mode):
		if dark_mode:
			%Icon.self_modulate = Settings.NORD_06
		else:
			%Icon.self_modulate = Settings.NORD_00
	)

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


func _on_search_query_focus_exited() -> void:
	theme_type_variation = "SearchBar"


func _on_search_query_text_changed(new_text: String) -> void:
	Settings.search_query = new_text


func _on_search_query_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		%SearchQuery.text = ""
		%SearchQuery.text_changed.emit("")


func _on_search_query_text_submitted(_new_text: String) -> void:
	%SearchQuery.release_focus()
