extends VBoxContainer


const SEARCH_RESULT := preload("search_result/search_result.tscn")


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Global Signals
	Settings.main_panel_changed.connect(func():
		visible = (Settings.main_panel == Settings.MainPanelState.GLOBAL_SEARCH)
	)

	# Deferred to give to-do lists with pending saves time to update their cache
	EventBus.global_search_requested.connect(search, CONNECT_DEFERRED)
	#endregion

	#region Local Signals
	$SaveSearch.pressed.connect(_on_save_search_pressed)
	#endregion


func search() -> void:
	# Remove previous results (if there are any).
	for child in %SearchResults.get_children():
		child.free()

	# Reverse key order: future dates first, past dates last.
	var cache_keys := Cache.data.keys()
	cache_keys.sort_custom(func(a, b): return a > b)

	# Search all cached contents for items matching the search query.
	for key in cache_keys:
		# FIXME: Temporary workaround, since the capture has no associated date,
		# thus it's not possible to jump to a captured to-do item yet
		if key == "capture" or key == "saved_searches":
			continue  # with next key

		var search_result_group := preload(
			"search_result_group/seach_result_group.tscn"
		).instantiate()
		search_result_group.date = Date.from_string(key)

		var line_id := 0
		for line in Cache.data[key].content:
			var stripped_line := Utils.strip_tags(line)
			if stripped_line.contains(Settings.search_query):
				var search_result := SEARCH_RESULT.instantiate()
				search_result.fill_in(key, stripped_line, line_id)
				search_result_group.add_result(search_result)
			line_id += 1

		if search_result_group.contains_results():
			$%SearchResults.add_child(search_result_group)

	# If there were no matching items, show the NoHitMessage instead.
	$NoHitMessage.visible = (%SearchResults.get_child_count() == 0)

	# Update the SaveSearch button depending on the current query text.
	if "saved_searches" in Cache.data:
		if Settings.search_query in Cache.data["saved_searches"].content:
			$SaveSearch.text = $SaveSearch.text.replace("Save", "Unsave")
		else:
			$SaveSearch.text = $SaveSearch.text.replace("Unsave", "Save")

	# Now, make the global search results panel visible to the user.
	Settings.main_panel = Settings.MainPanelState.GLOBAL_SEARCH


func _on_save_search_pressed() -> void:
	if not "saved_searches" in Cache.data:
		Cache.data["saved_searches"] = {
			"content": [],
			"last_modified": Time.get_unix_time_from_system()
		}

	if Settings.search_query in Cache.data["saved_searches"].content:
		var new_content := Cache.data["saved_searches"].content as Array
		new_content.erase(Settings.search_query)

		Cache.update_content(
			"saved_searches",
			"\n".join(new_content)
		)

		$SaveSearch.text = $SaveSearch.text.replace("Unsave", "Save")
	else:
		var new_content := Cache.data["saved_searches"].content as Array
		new_content.append(Settings.search_query)

		Cache.update_content(
			"saved_searches",
			"\n".join(new_content)
		)

		$SaveSearch.text = $SaveSearch.text.replace("Save", "Unsave")
