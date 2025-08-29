extends Node


var lists := {}

var _valid_filename_reg_ex = RegEx.create_from_string(
	"[0-9]{4}-[0-9]{2}-[0-9]{2}.txt"
)


func _enter_tree() -> void:
	Settings.store_path_changed.connect(load_from_disk)


func load_from_disk() -> void:
	lists = {}  # delete old data (if any exists)

	var directory := DirAccess.open(Settings.store_path)
	if directory:
		for filename in directory.get_files():
			if not _is_valid_filename(filename):
				continue  # with the next file

			var list = preload("types/todo_list.gd").new(
				Settings.store_path.path_join(filename)
			)

			if list.items.size() > 0:
				lists[filename.trim_suffix(".txt")] = list


func _is_valid_filename(filename: String) -> bool:
	return _valid_filename_reg_ex.search(filename) != null
