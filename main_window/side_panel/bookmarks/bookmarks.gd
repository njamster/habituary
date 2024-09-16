extends VBoxContainer


func _ready() -> void:
	EventBus.bookmark_added.connect(_on_bookmark_added)
	EventBus.bookmark_text_changed.connect(_on_bookmark_text_changed)
	EventBus.bookmark_removed.connect(_on_bookmark_removed)

	%List.child_entered_tree.connect(func(_node): $None.hide())
	%List.child_exiting_tree.connect(func(_node):
		$None.visible = (%List.get_child_count() == 1)
	)


func _add_bookmark(date : Date, todo_text : String) -> void:
	var bookmark := preload("bookmark/bookmark.tscn").instantiate()
	bookmark.date = date
	bookmark.text = todo_text
	%List.add_child(bookmark)

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


func _on_bookmark_removed(to_do : Control) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date := Date.new(to_do.get_node("../../../../..").date.as_dict())

	for bookmark in %List.get_children():
		if bookmark.text == to_do.text and bookmark.date.day_difference_to(date) == 0:
			bookmark.queue_free()
			return
