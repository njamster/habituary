extends VBoxContainer


const SEARCH_RESULT := preload("search_result/search_result.tscn")


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	Settings.main_panel_changed.connect(func():
		visible = (Settings.main_panel == Settings.MainPanelState.GLOBAL_SEARCH)
	)

	EventBus.global_search_requested.connect(search)

	Data.changed.connect(func():
		if Settings.main_panel == Settings.MainPanelState.GLOBAL_SEARCH:
			search()
	)
	#endregion

	#region Local Signals
	$BookmarkSearch.pressed.connect(_on_save_search_pressed)
	#endregion


func search() -> void:
	# Remove previous results (if there are any).
	for child in %SearchResults.get_children():
		child.free()

	# Reverse order: future dates first, past dates last.
	var filenames := Data.files.keys()
	filenames.sort_custom(func(a, b): return a > b)

	# Search all files for to-dos that match the search query.
	for filename in filenames:
		var date = filename.trim_suffix(".txt")

		var search_result_group := preload(
			"search_result_group/seach_result_group.tscn"
		).instantiate()
		search_result_group.date = Date.from_string(date)

		var to_do_list := Data.files[filename].to_do_list
		for to_do in to_do_list.search(Settings.search_query):
			var search_result := SEARCH_RESULT.instantiate()
			search_result.fill_in(date, to_do)
			search_result_group.add_result(search_result)

		if search_result_group.contains_results():
			$%SearchResults.add_child(search_result_group)
		else:
			search_result_group.queue_free()

	# If there were no matching items, show the NoHitMessage instead.
	$NoHitMessage.visible = (%SearchResults.get_child_count() == 0)

	# Update the BookmarkSearch button depending on the current query text.
	if Data.bookmarks.contains(Settings.search_query):
		$BookmarkSearch.text = "Remove Bookmark"
		$BookmarkSearch.icon = preload("images/remove_bookmark.svg")
	else:
		$BookmarkSearch.text = "Bookmark This Search"
		$BookmarkSearch.icon = preload("images/add_bookmark.svg")

	# Now, make the global search results panel visible to the user.
	Settings.main_panel = Settings.MainPanelState.GLOBAL_SEARCH


func _on_save_search_pressed() -> void:
	if Data.bookmarks.contains(Settings.search_query):
		Data.bookmarks.remove(Settings.search_query)
		$BookmarkSearch.text = "Bookmark This Search"
		$BookmarkSearch.icon = preload("images/add_bookmark.svg")
	else:
		Data.bookmarks.add(Settings.search_query)
		$BookmarkSearch.text = "Remove Bookmark"
		$BookmarkSearch.icon = preload("images/remove_bookmark.svg")
