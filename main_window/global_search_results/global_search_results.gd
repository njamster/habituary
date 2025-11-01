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

	Cache.content_updated.connect(func(key):
		if Settings.main_panel == Settings.MainPanelState.GLOBAL_SEARCH:
			for search_result_group in %SearchResults.get_children():
				if key == search_result_group.date.as_string():
					search()
					break  # for loop early
	)
	#endregion

	#region Local Signals
	$SaveSearch.pressed.connect(_on_save_search_pressed)
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

		var line_id := 0
		for to_do in Data.files[filename].to_do_list.to_dos:
			if to_do.text.contains(Settings.search_query):
				var search_result := SEARCH_RESULT.instantiate()
				search_result.fill_in(date, to_do.state, to_do.text, line_id)
				search_result_group.add_result(search_result)
			line_id += 1

		if search_result_group.contains_results():
			$%SearchResults.add_child(search_result_group)
		else:
			search_result_group.queue_free()

	# If there were no matching items, show the NoHitMessage instead.
	$NoHitMessage.visible = (%SearchResults.get_child_count() == 0)

	# Update the SaveSearch button depending on the current query text.
	if "saved_searches" in Cache.data:
		var matching_saved_search := false
		for raw_line in Cache.data["saved_searches"].content:
			var alarm_tag_reg_ex := RegEx.new()
			alarm_tag_reg_ex.compile("\\[ALARM:(?<alarm>[\\+|-][1-9][0-9]*)\\]$")
			var line := alarm_tag_reg_ex.sub(raw_line, "").strip_edges()

			if line == Settings.search_query:
				matching_saved_search = true
				break  # for loop

		if matching_saved_search:
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

	var matching_saved_search := ""
	for raw_line in Cache.data["saved_searches"].content:
		var alarm_tag_reg_ex := RegEx.new()
		alarm_tag_reg_ex.compile("\\[ALARM:(?<alarm>[\\+|-][1-9][0-9]*)\\]$")
		var line := alarm_tag_reg_ex.sub(raw_line, "").strip_edges()

		if line == Settings.search_query:
			matching_saved_search = raw_line
			break  # for loop

	if matching_saved_search:
		var new_content := Cache.data["saved_searches"].content as Array
		new_content.erase(matching_saved_search)

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
