extends Control


func _ready() -> void:
	if OS.is_debug_build():
		change_to_main_scene.call_deferred()
		return

	# check if the user already set the store path
	var config := ConfigFile.new()
	var error := config.load(Settings.SETTINGS_PATH)
	if not error:
		if config.has_section_key("Settings", "store_path"):
			var store_path = config.get_value("Settings", "store_path")
			if DirAccess.dir_exists_absolute(store_path):
				Settings.store_path = store_path
				change_to_main_scene.call_deferred()
				return

	get_window().min_size = size

	%Path.text = Settings.store_path
	%BrowseFiles.grab_focus()


func _on_browse_files_pressed() -> void:
	if DirAccess.dir_exists_absolute(%Path.text):
		$FileDialog.current_path = %Path.text
	else:
		$FileDialog.current_path = Settings.store_path
	$FileDialog.popup_centered()


func _on_file_dialog_dir_selected(dir_path : String) -> void:
	%Path.text = dir_path


func _on_confirm_pressed() -> void:
	DirAccess.make_dir_recursive_absolute(%Path.text)

	# permanently save store path
	var config = ConfigFile.new()
	config.load(Settings.SETTINGS_PATH) # keep existing settings (if there are any)
	config.set_value("Settings", "store_path", %Path.text)
	config.save(Settings.SETTINGS_PATH)

	Settings.store_path = %Path.text
	change_to_main_scene()


func change_to_main_scene() -> void:
	get_tree().change_scene_to_file("res://main_window/main_window.tscn")
