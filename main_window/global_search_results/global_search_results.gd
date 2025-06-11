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
	#endregion


func search() -> void:
	# Remove previous results (if there are any).
	for child in %SearchResults.get_children():
		child.free()

	# Reverse key order: future dates first, past dates last.
	var cache_keys := Cache.data.keys()
	cache_keys.reverse()

	# Search all cached contents for items matching the search query.
	for key in cache_keys:
		# FIXME: Temporary workaround, since the capture has no associated date,
		# thus it's not possible to jump to a captured to-do item yet
		if key == "capture":
			continue  # with next key

		var line_id := 0
		for line in Cache.data[key].content:
			if line.contains(Settings.search_query):
				var search_result := SEARCH_RESULT.instantiate()
				search_result.fill_in(key, line, line_id)
				%SearchResults.add_child(search_result)
			line_id += 1

	# If there were no matching items, show the NoHitMessage instead.
	$NoHitMessage.visible = (%SearchResults.get_child_count() == 0)

	# Now, make the global search results panel visible to the user.
	Settings.main_panel = Settings.MainPanelState.GLOBAL_SEARCH
