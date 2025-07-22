extends VBoxContainer


const SAVED_ITEM := preload("saved_item/saved_item.tscn")


func _ready() -> void:
	_load_from_disk()
	$NoneSaved.visible = (%Items.get_child_count() == 0)
	_resort_list()


func _load_from_disk() -> void:
	var filename := Settings.store_path.path_join("saved_searches.txt")
	var file := FileAccess.open(filename, FileAccess.READ)
	if file:
		while file.get_position() < file.get_length():
			var line := file.get_line()

			var new_item := SAVED_ITEM.instantiate()
			new_item.text = line
			%Items.add_child(new_item)


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
