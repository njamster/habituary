extends Node


var files: Dictionary[String, FileData]

var _valid_filename_reg_ex = RegEx.create_from_string(
	"[0-9]{4}-[0-9]{2}-[0-9]{2}.txt"
)


func _enter_tree() -> void:
	Settings.store_path_changed.connect(load_from_disk)


func load_from_disk() -> void:
	files = {}  # delete old data (if any exists)

	var directory := DirAccess.open(Settings.store_path)
	if directory:
		for filename in directory.get_files():
			if not _is_valid_filename(filename):
				continue  # with the next file

			var file = FileData.new(
				Settings.store_path.path_join(filename)
			)

			if not file.is_empty():
				files[filename.trim_suffix(".txt")] = file


func _is_valid_filename(filename: String) -> bool:
	return _valid_filename_reg_ex.search(filename) != null
