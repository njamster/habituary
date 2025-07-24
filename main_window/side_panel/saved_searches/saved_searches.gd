extends VBoxContainer


const SAVED_ITEM := preload("saved_item/saved_item.tscn")


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	_load_from_disk()


func _connect_signals() -> void:
	#region Global Signals
	Cache.content_updated.connect(func(key):
		if key == "saved_searches":
			_load_from_disk()
	)
	#endregion


func _load_from_disk() -> void:
	# remove previous entries (if there are any)
	for item in %Items.get_children():
		item.queue_free()

	# add new entries based on the cached lines
	if "saved_searches" in Cache.data:
		for line in Cache.data["saved_searches"].content:
			var new_item := SAVED_ITEM.instantiate()
			new_item.text = line
			%Items.add_child(new_item)
		_resort_list()

		$NoneSaved.hide()
	else:
		$NoneSaved.show()


func _resort_list() -> void:
	var items := %Items.get_children()

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
