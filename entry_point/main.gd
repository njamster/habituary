extends CenterContainer

## The [PackedScene] that the scene tree will be changed to after the user chose
## a valid store path and pressed the "Confirm" button.
@export var main_scene := preload("res://main_window/main.tscn")


func _ready() -> void:
	_connect_signals()

	$FileDialog.hide()
	%ErrorMessage.visible_ratio = 0.0

	if not OS.has_feature("editor"):
		#region Check if `store_path` is already set
		var config := ConfigFile.new()
		var error := config.load(Settings.settings_path)
		if not error:
			# If a settings file exists...
			if config.has_section_key("Settings", "store_path"):
				# ... it contains a `store_path` key...
				Settings.store_path = config.get_value("Settings", "store_path")
				if DirAccess.dir_exists_absolute(Settings.store_path):
					# ... and its value is (still?) valid, accept it and change to the main scene.
					get_tree().change_scene_to_packed.call_deferred(main_scene)
				else:
					# ... and its value is *not* valid (anymore?), show an error message.
					%ErrorMessage.visible_ratio = 1.0
					%Confirm.focus_mode = FOCUS_NONE
					%Confirm.disabled = true
		#endregion

	%DirectoryPath.text = Settings.store_path
	%BrowseFiles.grab_focus()


func _connect_signals() -> void:
	#region Local Signals
	%BrowseFiles.pressed.connect(_on_browse_files_pressed)

	%Confirm.pressed.connect(_on_confirm_pressed)

	$FileDialog.dir_selected.connect(_on_file_dialog_dir_selected)
	#endregion


func _on_browse_files_pressed() -> void:
	if DirAccess.dir_exists_absolute(Settings.store_path):
		$FileDialog.current_path = Settings.store_path
	elif OS.has_feature("windows"):
		$FileDialog.current_path = OS.get_environment("USERPROFILE") + "/"
	else:
		$FileDialog.current_path = OS.get_environment("HOME") + "/"

	$FileDialog.popup_centered()


func _on_file_dialog_dir_selected(path_to_directory : String) -> void:
	%DirectoryPath.text = path_to_directory
	Settings.store_path = path_to_directory
	%ErrorMessage.visible_ratio = 0.0
	%Confirm.focus_mode = FOCUS_ALL
	%Confirm.disabled = false


func _on_confirm_pressed() -> void:
	if Settings.store_path == Settings.DEFAULT_STORE_PATH:
		DirAccess.make_dir_recursive_absolute(Settings.store_path)

	if not DirAccess.dir_exists_absolute(Settings.store_path):
		%ErrorMessage.visible_ratio = 1.0
		%Confirm.focus_mode = FOCUS_NONE
		%Confirm.disabled = true
		%BrowseFiles.grab_focus()
		return # early

	if not OS.has_feature("editor"):
		#region Save `store_path` to disk
		var config = ConfigFile.new()
		config.load(Settings.settings_path) # keep existing settings (if there are any)
		config.set_value("Settings", "store_path", Settings.store_path)
		config.save(Settings.settings_path)
		#endregion

	get_tree().change_scene_to_packed.call_deferred(main_scene)
