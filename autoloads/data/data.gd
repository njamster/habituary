extends Node


var _valid_filename_reg_ex = RegEx.create_from_string(
	"^(?<year>[0-9]{4})-(?<month>0[1-9]|1[012])-(?<day>0[1-9]|[1-9][0-9]).txt$"
)


func _enter_tree() -> void:
	Settings.store_path_changed.connect(_load_from_disk)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_load_from_disk(false)


func _load_from_disk(replace_old_data := true) -> void:
	if replace_old_data:
		for child in get_children():
			unload(child)

	var directory := DirAccess.open(Settings.store_path)
	if directory:
		for filename in directory.get_files():
			if not _is_valid_filename(filename) or \
					get_node_or_null(filename.get_basename()):
						continue  # with the next file

			var new_file = FileData.new(
				Settings.store_path.path_join(filename)
			)

			if not new_file.is_empty():
				add_child(new_file)


func _is_valid_filename(filename: String) -> bool:
	var regex_match = _valid_filename_reg_ex.search(filename)
	if not regex_match:
		return false

	var day := int(regex_match.get_string("day"))
	var month := int(regex_match.get_string("month"))
	var year := int(regex_match.get_string("year"))
	if day > Date._days_in_month(month, year):
		return false

	return true


func unload(child: FileData) -> void:
	remove_child(child)
	child.queue_free()
