extends RefCounted
class_name BookmarkData


signal changed(reason: String)

var name := "bookmarks.txt"
var path := Settings.store_path.path_join(name)
var last_modified := Utils.MIN_INT

var _alarm_tag_reg_ex = RegEx.create_from_string(
	"\\[ALARM:(?<alarm>[\\+|-][1-9][0-9]*)\\]$"
)

var _queries := {}


func _init() -> void:
	_load_from_disk()

	changed.connect(Data.start_debounce_timer.bind(self))


func _load_from_disk() -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		last_modified = FileAccess.get_modified_time(path)

		while file.get_position() < file.get_length():
			var next_line := file.get_line()
			if not next_line.is_empty():
				var alarm_tag_reg_ex_match := _alarm_tag_reg_ex.search(next_line)
				if alarm_tag_reg_ex_match:
					var query = next_line.substr(
						0,
						alarm_tag_reg_ex_match.get_start()
					).strip_edges()
					var warning_threshold = int(
						alarm_tag_reg_ex_match.get_string("alarm")
					)
					_queries[query] = warning_threshold
				else:
					_queries[next_line] = null


func save_to_disk() -> void:
	if not _queries.is_empty():
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.store_string(as_string())
		Log.debug("[%s] Saved to disk" % name)
	else:
		DirAccess.remove_absolute(path)


func reload() -> void:
	if last_modified < FileAccess.get_modified_time(path):
		_load_from_disk()


func as_string() -> String:
	var result := ""

	for query in _queries.keys():
		if _queries[query]:
			var warning_threshold = _queries[query]
			if warning_threshold > 0:
				result += "%s [ALARM:+%d]\n" % [
					query,
					warning_threshold
				]
			else:
				result += "%s [ALARM:%d]\n" % [
					query,
					warning_threshold
				]
		else:
			result += query + "\n"

	return result.trim_suffix("\n")


func is_empty() -> bool:
	return _queries.is_empty()


func add(query: String, warning_threshold = null) -> void:
	if query not in _queries:
		_queries[query] = warning_threshold
		changed.emit("Query added")


func contains(query: String) -> bool:
	return query in _queries


func update(query: String, warning_threshold = null) -> void:
	if contains(query) and _queries[query] != warning_threshold:
		_queries[query] = warning_threshold
		changed.emit("Warning threshold changed")


func remove(query: String) -> void:
	if contains(query):
		_queries.erase(query)
		changed.emit("Query removed")
