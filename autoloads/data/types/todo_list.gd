extends RefCounted


var file_path: String

var items := []


func _init(p_file_path: String) -> void:
	file_path = p_file_path
	_load_from_disk()


func _load_from_disk() -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file:
		while file.get_position() < file.get_length():
			var next_line := file.get_line()
			if not next_line.is_empty():
				var item := preload("to_do.gd").new(next_line)

				if not item.text.is_empty():
					items.append(item)


func as_string() -> String:
	var result := ""

	for item in items:
		result += item.as_string() + "\n"

	return result.trim_suffix("\n")
