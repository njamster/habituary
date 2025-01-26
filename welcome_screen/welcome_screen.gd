extends CenterContainer


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	$FileDialog.hide()

	if Settings.store_path:
		_update_directory_path(Settings.store_path)
	else:
		_update_directory_path(Settings.DEFAULT_STORE_PATH)


func _connect_signals() -> void:
	#region Local Signals
	%BrowseFiles.pressed.connect(_open_file_dialog)

	%Confirm.pressed.connect(_try_changing_to_main_scene)

	$FileDialog.dir_selected.connect(_update_directory_path)
	#endregion


func _open_file_dialog() -> void:
	if DirAccess.dir_exists_absolute(%DirectoryPath.text):
		$FileDialog.current_path = %DirectoryPath.text
	elif OS.has_feature("windows"):
		$FileDialog.current_path = OS.get_environment("USERPROFILE") + "/"
	else:
		$FileDialog.current_path = OS.get_environment("HOME") + "/"

	$FileDialog.popup_centered()


func _update_directory_path(path: String) -> void:
	%DirectoryPath.text = path

	if DirAccess.dir_exists_absolute(%DirectoryPath.text):
		_hide_error_message()
	else:
		_show_error_message()


func _show_error_message() -> void:
	%ErrorMessage.visible_ratio = 1.0

	%Confirm.focus_mode = FOCUS_NONE
	%Confirm.disabled = true

	%BrowseFiles.grab_focus()


func _hide_error_message() -> void:
	%ErrorMessage.visible_ratio = 0.0

	%Confirm.focus_mode = FOCUS_ALL
	%Confirm.disabled = false

	%Confirm.grab_focus()


func _try_changing_to_main_scene() -> void:
	if DirAccess.dir_exists_absolute(%DirectoryPath.text):
		Settings.store_path = %DirectoryPath.text
		get_tree().change_scene_to_file.call_deferred(
			"res://main_window/main_window.tscn"
		)
	else:
		_show_error_message()
