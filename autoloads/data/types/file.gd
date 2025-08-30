extends RefCounted
class_name FileData


var path: String

var to_do_list := ToDoListData.new()


func _init(p_file_path: String) -> void:
	path = p_file_path
	_load_from_disk()

	print(as_string())


func _load_from_disk() -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		while file.get_position() < file.get_length():
			var next_line := file.get_line()
			if not next_line.is_empty():
				var to_do := ToDoData.new(next_line)

				if not to_do.text.is_empty():
					to_do_list.add(to_do)


func as_string() -> String:
	var result := ""

	for item in to_do_list.to_dos:
		result += item.as_string() + "\n"

	return result.trim_suffix("\n")


func is_empty() -> bool:
	return to_do_list.is_empty()
