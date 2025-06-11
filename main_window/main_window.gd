extends MarginContainer


func _enter_tree() -> void:
	if not Settings.store_path or not DirAccess.dir_exists_absolute(Settings.store_path):
		get_tree().change_scene_to_file.call_deferred(
			"res://welcome_screen/welcome_screen.tscn"
		)


func _ready() -> void:
	_set_initial_state()


func _set_initial_state() -> void:
	%ListView.show()
	%GlobalSearchResults.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()

		if $Overlay.visible:
			$Overlay.close_overlay()
	elif event.is_action_pressed("ui_cancel"):
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()
			return

		if Settings.previous_day and Settings.previous_view_mode:
			# restore previous values
			Settings.current_day = Settings.previous_day
			Settings.view_mode = Settings.previous_view_mode
			# clear the cached values
			Settings.previous_day = null
			Settings.previous_view_mode = null
	elif event.is_action_pressed("toggle_fullscreen"):
		Settings.is_fullscreen = not Settings.is_fullscreen
