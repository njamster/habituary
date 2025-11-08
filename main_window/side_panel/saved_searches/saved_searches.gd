extends VBoxContainer


const SAVED_ITEM := preload("saved_item/saved_item.tscn")


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	_load_from_disk()


func _connect_signals() -> void:
	#region Global Signals
	Data.saved_searches.changed.connect(_load_from_disk.unbind(1))
	#endregion


func _load_from_disk() -> void:
	# remove previous entries (if there are any)
	for item in %Items.get_children():
		item.queue_free()

	for query in Data.saved_searches._queries.keys():
		var new_item := SAVED_ITEM.instantiate()
		new_item.text = query
		new_item.warning_threshold = Data.saved_searches._queries[query]
		new_item.resort_requested.connect(_resort_list)
		%Items.add_child(new_item)

	if %Items.get_child_count():
		$NoneSaved.hide()


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

	# reorder bookmarks to match the sorted bookmarks
	for j in items.size():
		var item = items[j]
		if item.get_index() != j:
			%Items.move_child(item, j)
