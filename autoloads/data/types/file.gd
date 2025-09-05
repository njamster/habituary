extends RefCounted
class_name FileData


var path: String
var name: String
var last_modified := Utils.MIN_INT

var to_do_list := ToDoListData.new()


func _init(p_file_path: String) -> void:
	path = p_file_path
	name = path.get_file()
	_load_from_disk()


func _load_from_disk() -> void:
	if to_do_list.changed.is_connected(Data.start_debounce_timer):
		to_do_list.changed.disconnect(Data.start_debounce_timer)

	to_do_list.clear()  # delete old data (if there's any)

	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		last_modified = FileAccess.get_modified_time(path)

		while file.get_position() < file.get_length():
			var next_line := file.get_line()
			if not next_line.is_empty():
				var to_do := ToDoData.new()
				to_do_list.add(to_do)
				to_do.load_from_string(next_line)

	to_do_list.changed.connect(Data.start_debounce_timer.bind(self))


func save_to_disk() -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(as_string())


func reload() -> void:
	if not FileAccess.file_exists(path):
		Data.unload(self)
		return  # early

	if last_modified < FileAccess.get_modified_time(path):
		_load_from_disk()

		if is_empty():
			Data.unload(self)


func as_string() -> String:
	var result := ""

	for item in to_do_list.to_dos:
		result += item.as_string() + "\n"

	return result.trim_suffix("\n")


func is_empty() -> bool:
	return to_do_list.is_empty()
