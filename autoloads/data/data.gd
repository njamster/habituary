extends Node


signal changed()

const DEBOUNCE_TIME := 10.0  # seconds

var files: Dictionary[String, FileData]
var bookmarks: BookmarkData
var capture: FileData

var _valid_filename_reg_ex = RegEx.create_from_string(
	"^(?<year>[0-9]{4})-(?<month>0[1-9]|1[012])-(?<day>0[1-9]|[1-9][0-9]).txt$"
)


func _enter_tree() -> void:
	capture = FileData.new(Settings.store_path.path_join("capture.txt"))
	bookmarks = BookmarkData.new()

	Settings.store_path_changed.connect(_load_from_disk)


func _notification(what: int) -> void:
	if what in [
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_FOCUS_OUT
	]:
		for timer in get_children():
			timer.timeout.emit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_load_from_disk(false)


func _load_from_disk(replace_old_data := true) -> void:
	if replace_old_data:
		capture = FileData.new(Settings.store_path.path_join("capture.txt"))
		capture.reloaded.connect(changed.emit)
		files.clear()
		bookmarks = BookmarkData.new()
	else:
		capture.reload()
		for key in files.keys():
			files[key].reload()
		bookmarks.reload()

	var directory := DirAccess.open(Settings.store_path)
	if directory:
		for filename in directory.get_files():
			if not _is_valid_filename(filename) or filename in files:
				continue  # with the next file

			var new_file = FileData.new(
				Settings.store_path.path_join(filename)
			)
			new_file.reloaded.connect(changed.emit)

			if not new_file.is_empty():
				files[filename] = new_file


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


func start_debounce_timer(reason: String, file: RefCounted) -> void:
	changed.emit()

	var filename_without_extension: String = file.name.replace(".txt", "")
	var debounce_timer: Timer = get_node_or_null(filename_without_extension)
	if debounce_timer:
		debounce_timer.start()
		Log.debug("[%s] Debounce timer restarted, reason: %s" % [
			file.name,
			reason
		])
	else:
		debounce_timer = Timer.new()
		debounce_timer.name = filename_without_extension
		debounce_timer.wait_time = DEBOUNCE_TIME
		debounce_timer.autostart = true
		debounce_timer.one_shot = true
		debounce_timer.timeout.connect(func():
			file.save_to_disk()
			debounce_timer.queue_free()
		)
		add_child(debounce_timer)
		Log.debug("[%s] Debounce timer started, reason: %s" % [
			file.name,
			reason
		])


func unload(file: FileData) -> void:
	if file.name in files:
		if not file.keep_loaded:
			Log.debug("[%s] Unloaded" % file.name)
			files.erase(file.name)


func get_file(filename: String) -> FileData:
	if not filename in files:
		files[filename] = FileData.new(
			Settings.store_path.path_join(filename)
		)
	return files[filename]


func has_file(filename: String) -> bool:
	return (
		filename in files
		and not files[filename].is_empty()
	)
