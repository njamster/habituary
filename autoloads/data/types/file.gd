extends Timer
class_name FileData


const DEBOUNCE_TIME := 10.0  # seconds

var path: String
var last_modified := Utils.MIN_INT

var to_do_list := ToDoListData.new()


func _init(p_file_path: String) -> void:
	path = p_file_path

	name = p_file_path.get_file().get_basename()

	_load_from_disk()


func _ready() -> void:
	one_shot = true
	wait_time = DEBOUNCE_TIME
	timeout.connect(_save_to_disk)

	to_do_list.changed.connect(start)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if not is_stopped():
			_save_to_disk()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if is_inside_tree():
			_reload()


func _load_from_disk() -> void:
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


func _save_to_disk() -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(as_string())


func _reload() -> void:
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
