extends VBoxContainer


func _ready() -> void:
	_search_for_bookmarks()

	EventBus.bookmark_added.connect(_on_bookmark_added)
	EventBus.bookmark_text_changed.connect(_on_bookmark_text_changed)
	EventBus.bookmark_date_changed.connect(_on_bookmark_date_changed)
	EventBus.bookmark_removed.connect(_on_bookmark_removed)


func _search_for_bookmarks() -> void:
	var directory := DirAccess.open(Settings.store_path)
	if directory:
		for file_name in directory.get_files():
			var file = FileAccess.open(Settings.store_path.path_join(file_name), FileAccess.READ)
			if file:
				while file.get_position() < file.get_length():
					var line := file.get_line()
					if line.ends_with( " [BOOKMARK]"):
						# FIXME: avoid replicating the entire line parsing from todo_item.gd here
						if line.begins_with("# ") or line.begins_with("v ") or line.begins_with("> "):
							line = line.right(-2)
						elif line.begins_with("[ ] ") or line.begins_with("[x] ") or line.begins_with("[-] "):
							line = line.right(-4)

						if line.begins_with("**") and  line.ends_with("**"):
							line = line.substr(2, line.length() - 4)
						if line.begins_with("*") and  line.ends_with("*"):
							line = line.substr(1, line.length() - 2)

						_add_bookmark(
							Date.from_string(file_name.left(-4)),
							line.substr(0, line.length() - 11)
						)
			else:
				pass  # FIXME: print error?
	else:
		pass  # FIXME: print error?


func _add_bookmark(date : Date, todo_text : String) -> void:
	var bookmark := preload("bookmark/bookmark.tscn").instantiate()
	bookmark.date = date
	bookmark.text = todo_text
	%List.add_child(bookmark)

	$None.hide()

	for i in %List.get_child_count():
		var child = %List.get_child(i)
		if child.date.day_difference_to(date) > 0:
			%List.move_child(bookmark, i)
			return


func _on_bookmark_added(to_do : Control) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date := Date.new(to_do.get_node("../../../../..").date.as_dict())

	for bookmark in %List.get_children():
		if bookmark.text == to_do.text and bookmark.date.day_difference_to(date) == 0:
			return

	_add_bookmark(date, to_do.text)


func _on_bookmark_text_changed(to_do : Control, old_text : String) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date := Date.new(to_do.get_node("../../../../..").date.as_dict())

	for bookmark in %List.get_children():
		if bookmark.text == old_text and bookmark.date.day_difference_to(date) == 0:
			bookmark.text = to_do.text
			return


func _on_bookmark_date_changed(to_do : Control, old_date : Date) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var new_date := Date.new(to_do.get_node("../../../../..").date.as_dict())

	for bookmark in %List.get_children():
		if bookmark.text == to_do.text and bookmark.date.day_difference_to(old_date) == 0:
			bookmark.date = new_date
			return


func _on_bookmark_removed(to_do : Control) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date := Date.new(to_do.get_node("../../../../..").date.as_dict())

	for bookmark in %List.get_children():
		if bookmark.text == to_do.text and bookmark.date.day_difference_to(date) == 0:
			$None.visible = (%List.get_child_count() == 1)
			bookmark.queue_free()
			return
