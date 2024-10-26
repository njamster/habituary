extends VBoxContainer


func _ready() -> void:
	$NoneSet.show()
	$IncludePast.hide()
	$IncludePast.set_pressed_no_signal(Settings.show_bookmarks_from_the_past)

	_search_for_bookmarks()

	EventBus.bookmark_added.connect(_on_bookmark_added)
	EventBus.bookmark_changed.connect(_on_bookmark_changed)
	EventBus.bookmark_removed.connect(_on_bookmark_removed)


func _search_for_bookmarks() -> void:
	var directory := DirAccess.open(Settings.store_path)
	if directory:
		for file_name in directory.get_files():
			var file = FileAccess.open(Settings.store_path.path_join(file_name), FileAccess.READ)
			if file:
				var line_number := -1
				while file.get_position() < file.get_length():
					var line := file.get_line()
					if line.begins_with("# ") or line.begins_with("v ") or line.begins_with("> ") \
						or line.begins_with("[ ] ") or line.begins_with("[x] ") or line.begins_with("[-] "):
							line_number += 1
					if line.ends_with( " [BOOKMARK]"):
						# remove the "[BOOKMARK]" tag
						line = line.substr(0, line.length() - 11)

						# FIXME: avoid replicating the entire line parsing from todo_item.gd here
						var is_done := false
						if line.begins_with("# ") or line.begins_with("v ") or line.begins_with("> "):
							line = line.right(-2)
						elif line.begins_with("[x] ") or line.begins_with("[-] "):
							line = line.right(-4)
							is_done = true
						elif line.begins_with("[ ] "):
							line = line.right(-4)

						if line.begins_with("**") and  line.ends_with("**"):
							line = line.substr(2, line.length() - 4)

						if line.begins_with("*") and  line.ends_with("*"):
							line = line.substr(1, line.length() - 2)

						_add_bookmark(
							Date.from_string(file_name.left(-4)),
							line_number,
							line,
							is_done
						)
			else:
				pass  # FIXME: print error?
	else:
		pass  # FIXME: print error?


func _add_bookmark(date : Date, line_number : int, todo_text : String, is_done := false) -> void:
	var bookmark := preload("bookmark/bookmark.tscn").instantiate()
	bookmark.date = date
	bookmark.line_number = line_number
	bookmark.text = todo_text
	bookmark.is_done = is_done
	%Items.add_child(bookmark)

	$NoneSet.hide()
	$IncludePast.show()

	for i in %Items.get_child_count():
		var child = %Items.get_child(i)
		if (child.date.day_difference_to(date) == 0 and child.line_number > line_number) \
			or child.date.day_difference_to(date) > 0:
				%Items.move_child(bookmark, i)
				return


func _resort_list() -> void:
	var bookmarks := %Items.get_children()

	# Sort bookmarks...
	bookmarks.sort_custom(func(a, b):
		# ... primarily by date...
		if a.day_diff < b.day_diff:
			return true
		elif a.day_diff == b.day_diff:
			# ... secondarily (if bookmark is due today) by state...
			if a.date.day_difference_to(DayTimer.today) <= 0 and a.is_done != b.is_done:
				return a.is_done
			# ... otherwise by line_number.
			elif a.line_number < b.line_number:
				return true
		else:
			return false
	)

	# reorder bookmarks to match the sorted bookmarks
	for j in bookmarks.size():
		var bookmark = bookmarks[j]
		if bookmark.get_index() != j:
			%Items.move_child(bookmark, j)


func _on_bookmark_added(to_do : Control) -> void:
	_add_bookmark(to_do.date, to_do.get_index(), to_do.text, to_do.state != to_do.States.TO_DO)


func _on_bookmark_changed(to_do : Control, old_date : Date, old_index : int) -> void:
	for bookmark in %Items.get_children():
		if bookmark.date.day_difference_to(old_date) == 0 and bookmark.line_number == old_index:
			bookmark.date = to_do.date
			bookmark.line_number = to_do.get_index()
			bookmark.text = to_do.text
			bookmark.is_done = (to_do.state != to_do.States.TO_DO)
			_resort_list.call_deferred()
			return


func _on_bookmark_removed(to_do : Control) -> void:
	var date = to_do.date
	var line_number := to_do.get_index()

	for bookmark in %Items.get_children():
		if bookmark.date.day_difference_to(date) == 0 and bookmark.line_number == line_number:
			$NoneSet.visible = (%Items.get_child_count() == 1)
			$IncludePast.visible = not $NoneSet.visible
			bookmark.queue_free()
			return


func _on_include_past_toggled(toggled_on: bool) -> void:
	Settings.show_bookmarks_from_the_past = toggled_on
