extends Node


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


func _load_directory(directory_path: String) -> void:
	var directory := DirAccess.open(directory_path)
	if directory:
		for filename in directory.get_files():
			_load_file(directory_path, filename)


func _load_file(directory_path: String, filename: String) -> void:
	if not _is_valid_filename(filename):
		return

	var full_path := directory_path.path_join(filename)
	var file := FileAccess.open(full_path, FileAccess.READ)
	if file:
		# Ignore empty files.
		if file.get_length() == 0:
			return

		if filename == "capture.txt":
			# Unless modified since then: Ignore already cached file.
			if "capture" in data:
				if data["capture"].last_modified >= \
					FileAccess.get_modified_time(full_path):
						return

			# Add the file's content and last modification date to the cache.
			data["capture"] = {
				"content": file.get_as_text(),
				"last_modified": FileAccess.get_modified_time(full_path)
			}
		else:
			# Derive year, month and date from the filename.
			var splits := filename.trim_suffix(".txt").split("-")
			var year = splits[0]
			var month = splits[1]
			var day = splits[2]

			# If it doesn't exist yet: Create nested dictionary structure.
			if not year in data:
				data[year] = {}
			if not month in data[year]:
				data[year][month] = {}

			# Unless modified since then: Ignore already cached files.
			if day in data[year][month]:
				if data[year][month][day].last_modified >= \
					FileAccess.get_modified_time(full_path):
						return

			# Add the file's content and last modification date to the cache.
			data[year][month][day] = {
				"content": file.get_as_text(),
				"last_modified": FileAccess.get_modified_time(full_path)
			}


func _is_valid_filename(filename: String) -> bool:
	return filename == "capture.txt" or \
		_valid_filename_reg_ex.search(filename) != null


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_load_directory(Settings.store_path)
