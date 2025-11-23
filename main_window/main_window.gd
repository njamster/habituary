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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		Settings.ui_scale_factor += 0.1
	elif event.is_action_pressed("zoom_out"):
		Settings.ui_scale_factor -= 0.1
	elif event.is_action_pressed("reset_zoom"):
		Settings.ui_scale_factor = 1.0
	elif event.is_action_pressed("toggle_fullscreen"):
		Settings.is_fullscreen = not Settings.is_fullscreen


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()
			return

		if Settings.memorized_day and Settings.memorized_view_mode:
			# restore previous values
			Settings.current_day = Settings.memorized_day
			Settings.view_mode = Settings.memorized_view_mode
			# clear the cached values
			Settings.memorized_day = null
			Settings.memorized_view_mode = null
