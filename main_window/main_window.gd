extends MarginContainer


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()

		if $Overlay.visible:
			$Overlay.close_overlay()
	elif event.is_action_pressed("toggle_fullscreen"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			_:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif event.is_action_pressed("ui_cancel"):
		if Settings.previous_day and Settings.previous_view_mode:
			# restore previous values
			Settings.current_day = Settings.previous_day
			Settings.view_mode = Settings.previous_view_mode
			# clear the cached values
			Settings.previous_day = null
			Settings.previous_view_mode = null
