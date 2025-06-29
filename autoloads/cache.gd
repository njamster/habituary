extends Node


signal content_updated(key)


var data := {}

var _valid_filename_reg_ex := RegEx.new()


func _enter_tree() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	_valid_filename_reg_ex.compile("[0-9]{4}-[0-9]{2}-[0-9]{2}.txt")


func _connect_signals() -> void:
	Settings.store_path_changed.connect(_on_store_path_changed)


func _on_store_path_changed() -> void:
	data = {}  # reset cached data

	if not Settings.sub_items_refactor_patch_applied:
		var directory := DirAccess.open(Settings.store_path)
		if directory:
			for filename in directory.get_files():
				_apply_sub_items_refactor_patch(Settings.store_path, filename)

		Settings.sub_items_refactor_patch_applied = true

	_load_directory(Settings.store_path)


func _apply_sub_items_refactor_patch(directory_path: String, filename: String) -> void:
	if not _is_valid_filename(filename):
		return

	var full_path := directory_path.path_join(filename)
	var file_to_patch := FileAccess.open(full_path, FileAccess.READ_WRITE)
	if file_to_patch:
		var new_content = ""

		var is_legacy_file = false
		var inside_heading = false
		while file_to_patch.get_position() < file_to_patch.get_length():
			var next_line := file_to_patch.get_line()

			if next_line.begins_with("  [") or next_line.begins_with("  >") or \
					next_line.begins_with("  v"):
						is_legacy_file = true

			while next_line.begins_with("  "):
				next_line = next_line.right(-2)
				new_content += "    "

			if next_line.begins_with("v "):
				is_legacy_file = true
				inside_heading = true
				next_line = next_line.right(-2)
				new_content += "[ ] "
			elif next_line.begins_with("> "):
				is_legacy_file = true
				inside_heading = true
				next_line = next_line.right(-2)
				new_content += "[ ] > "
			elif inside_heading:
				new_content += "    "

			new_content += next_line + "\n"

		if is_legacy_file:
			file_to_patch.resize(0) # erase the previous content
			file_to_patch.seek(0) # reset the writing cursor
			file_to_patch.store_string(new_content)


func _load_directory(directory_path: String, emit := false) -> void:
	var directory := DirAccess.open(directory_path)
	if directory:
		var file_list := directory.get_files()

		if emit:
			for key in data.keys():
				if not key + ".txt" in file_list:
					delete_key(key)
					content_updated.emit(key)

		for filename in file_list:
			_load_file(directory_path, filename, emit)


func _load_file(directory_path: String, filename: String, emit: bool) -> void:
	if not _is_valid_filename(filename):
		return

	var full_path := directory_path.path_join(filename)
	var file := FileAccess.open(full_path, FileAccess.READ)
	if file:
		# Ignore empty files.
		if file.get_length() == 0:
			return

		var key := filename.trim_suffix(".txt")

		# Unless modified since then: Ignore already cached files.
		if key in data:
			if data[key].last_modified >= \
				FileAccess.get_modified_time(full_path):
					return

		# Add the file's content and last modification date to the cache.
		data[key] = {
			"content": file.get_as_text().split("\n", false),
			"last_modified": FileAccess.get_modified_time(full_path)
		}

		if emit:
			content_updated.emit(key)


func _is_valid_filename(filename: String) -> bool:
	return filename == "capture.txt" or \
		_valid_filename_reg_ex.search(filename) != null


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_load_directory(Settings.store_path, true)


func get_store_path(key: String) -> String:
	return Settings.store_path.path_join(key + ".txt")


func save_to_disk(key: String) -> void:
	var store_path := get_store_path(key)

	if data[key].content:
		var file := FileAccess.open(store_path, FileAccess.WRITE)
		for line in data[key].content:
			file.store_line(line)
		file.close()

		data[key].last_modified = FileAccess.get_modified_time(store_path)


func update_content(key: String, content: String) -> void:
	if not key:
		return  # early

	if content:
		if key not in data:
			data[key] = {
				"content": content.split("\n", false),
				"last_modified": Time.get_unix_time_from_system()
			}
		else:
			data[key].content = content.split("\n", false)

		save_to_disk(key)
	else:
		delete_key(key)


func delete_key(key: String) -> void:
	if not key or key not in data:
		return  # early

	data.erase(key)

	DirAccess.remove_absolute(get_store_path(key))


func move_item(line_id: int, from: String, to: String) -> void:
	# Since content is a PackedStingArray, there's no pop_at() method.
	var item = data[from].content[line_id]
	data[from].content.remove_at(line_id)

	if to not in data:
		data[to] = {
			"content": [],
			"last_modified": Time.get_unix_time_from_system()
		}
	data[to].content.append(item)

	save_to_disk(to)
	content_updated.emit(to)

	save_to_disk(from)
	content_updated.emit(from)


func postpone_item(line_id: int, from: String, to: String) -> void:
	var item = data[from].content[line_id]

	var review_date_reg_ex := RegEx.new()
	review_date_reg_ex.compile("\\[REVIEW:(?<date>[0-9]{4}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01]))\\]")
	var review_date_reg_ex_match := review_date_reg_ex.search(item)
	if review_date_reg_ex_match:
		item = review_date_reg_ex.sub(item, "[REVIEW:%s]" % to)
	else:
		item += " [REVIEW:%s]" % to

	data[from].content[line_id] = item

	save_to_disk(from)
	content_updated.emit(from)
