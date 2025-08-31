extends Node


var files: Dictionary[String, FileData]

var _valid_filename_reg_ex = RegEx.create_from_string(
	"[0-9]{4}-[0-9]{2}-[0-9]{2}.txt"
)


func _enter_tree() -> void:
	Settings.store_path_changed.connect(_load_from_disk)


func _load_from_disk(replace_old_data := true) -> void:
	if replace_old_data:
		files.clear()

	var directory := DirAccess.open(Settings.store_path)
	if directory:
		# erase no longer existing files
		for key in files.keys():
			if not key in directory.get_files():
				files.erase(key)

		# cache all valid existing files
		for filename in directory.get_files():
			if not _is_valid_filename(filename):
				continue  # with the next file

			if filename in files:
				files[filename].reload()
			else:
				var file = FileData.new(
					Settings.store_path.path_join(filename)
				)

				if not file.is_empty():
					files[filename] = file


func _is_valid_filename(filename: String) -> bool:
	return _valid_filename_reg_ex.search(filename) != null


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_load_from_disk(false)
