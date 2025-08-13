extends VBoxContainer


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	$NoneSet.show()
	$IncludePast.hide()

	$IncludePast.set_pressed_no_signal(Settings.show_bookmarks_from_the_past)

	_search_for_bookmarks()


func _connect_signals() -> void:
	#region Global Signals
	EventBus.bookmark_added.connect(_on_bookmark_added)

	EventBus.bookmark_changed.connect(_on_bookmark_changed)

	EventBus.bookmark_indicator_clicked.connect(_on_bookmark_indicator_clicked)

	EventBus.bookmark_removed.connect(_on_bookmark_removed)
	#endregion

	#region Local Signals
	$IncludePast.toggled.connect(_on_include_past_toggled)
	#endregion


func _search_for_bookmarks() -> void:
	for key in Cache.data:
		var line_number = 0
		for line in Cache.data[key].content:
			line = line.strip_edges()

			if line.contains("[BOOKMARK]"):
				var stripped_line = Utils.strip_tags(line)
				if "[BOOKMARK]" not in stripped_line:
					_add_bookmark(
						Date.from_string(key),
						line_number,
						stripped_line,
						line.begins_with("[x] ") or line.begins_with("[-] ")
					)

			line_number += 1


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
		if (child.date.equals(date) and child.line_number > line_number) \
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
	_add_bookmark(
		to_do.date,
		to_do.get_list_index(),
		to_do.get_node("%Edit").text,
		to_do.state != to_do.States.TO_DO
	)


func _on_bookmark_changed(to_do : Control, old_date : Date, old_index : int) -> void:
	for bookmark in %Items.get_children():
		if bookmark.updated_this_frame:
			continue

		if bookmark.date.equals(old_date) and bookmark.line_number == old_index:
			bookmark.date = to_do.date
			bookmark.line_number = to_do.get_list_index()
			bookmark.text = to_do.get_node("%Edit").text
			bookmark.is_done = (to_do.state != to_do.States.TO_DO)
			bookmark.updated_this_frame = true

			_resort_list.call_deferred()

			bookmark.set_deferred("updated_this_frame", false)
			to_do.set_deferred("has_requested_bookmark_update", false)

			return


func _on_bookmark_indicator_clicked(date: Date, index: int) -> void:
	for bookmark in %Items.get_children():
		if bookmark.date.equals(date) and bookmark.line_number == index:
			bookmark.get_node("%JumpTo").grab_focus()
			return


func _on_bookmark_removed(to_do : Control) -> void:
	var date = to_do.date
	var line_number = to_do.get_list_index()

	for bookmark in %Items.get_children():
		if bookmark.date.equals(date) and bookmark.line_number == line_number:
			$NoneSet.visible = (%Items.get_child_count() == 1)
			$IncludePast.visible = not $NoneSet.visible
			bookmark.remove()
			return


func _on_include_past_toggled(toggled_on: bool) -> void:
	Settings.show_bookmarks_from_the_past = toggled_on
