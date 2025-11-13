extends VBoxContainer


const BOOKMARK := preload("bookmark/bookmark.tscn")


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	_load_from_disk()


func _connect_signals() -> void:
	#region Global Signals
	Data.bookmarks.changed.connect(_load_from_disk.unbind(1))

	EventBus.today_changed.connect(_load_from_disk)
	#endregion


func _load_from_disk() -> void:
	# remove previous entries (if there are any)
	for item in %Items.get_children():
		item.queue_free()

	Settings.bookmarks_due_today = 0
	for query in Data.bookmarks._queries.keys():
		var new_item := BOOKMARK.instantiate()
		new_item.text = query
		new_item.warning_threshold = Data.bookmarks._queries[query]
		new_item.resort_requested.connect(_resort_list)
		%Items.add_child(new_item)
		if new_item.is_due_today:
			Settings.bookmarks_due_today += 1

	$NoneSaved.visible = Data.bookmarks._queries.is_empty()


func _resort_list() -> void:
	var items := %Items.get_children()

	if items.size() < 2:
		return  # early

	# Sort bookmarks...
	items.sort_custom(func(a, b):
		# ... primarily by date...
		if a.day_diff < b.day_diff:
			return true
		# ... secondarily by line_id.
		elif a.day_diff == b.day_diff and a.line_id < b.line_id:
			return true
		else:
			return false
	)

	# reorder bookmarks to match the sorting
	for j in items.size():
		var item = items[j]
		if item.get_index() != j:
			%Items.move_child(item, j)
