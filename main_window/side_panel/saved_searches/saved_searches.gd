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

	#region Local Signals
	$DebounceTimer.timeout.connect(save_to_disk)
	#endregion


func _load_from_disk() -> void:
	# remove previous entries (if there are any)
	for item in %Items.get_children():
		item.free()

	# add new entries based on the cached lines
	if "saved_searches" in Cache.data:
		for raw_line in Cache.data["saved_searches"].content:
			var new_item := SAVED_ITEM.instantiate()
			var alarm_tag_reg_ex := RegEx.new()
			alarm_tag_reg_ex.compile("\\[ALARM:(?<alarm>[\\+|-][1-9][0-9]*)\\]$")
			var alarm_tag_reg_ex_match := alarm_tag_reg_ex.search(raw_line)
			if alarm_tag_reg_ex_match:
				new_item.text = raw_line.substr(
					0,
					alarm_tag_reg_ex_match.get_start()
				).strip_edges()
				new_item.warning_threshold = int(
					alarm_tag_reg_ex_match.get_string("alarm")
				)
			else:
				new_item.text = raw_line
			new_item.save_requested.connect(func():
				print("[DEBUG] Saved Search Save Requested: (Re)Starting DebounceTimer...")
				$DebounceTimer.start()
			)
			new_item.resort_requested.connect(_resort_list)
			%Items.add_child(new_item)

		$NoneSaved.hide()
	else:
		$NoneSaved.show()


func _resort_list() -> void:
	var items := %Items.get_children()

	if items.size() < 2:
		return  # early

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


func save_to_disk() -> void:
	var content = ""

	for item in %Items.get_children():
		if item.warning_threshold > Utils.MIN_INT:
			if item.warning_threshold > 0:
				content += "%s [ALARM:+%d]\n" % [
					item.text,
					item.warning_threshold
				]
			else:
				content += "%s [ALARM:%d]\n" % [
					item.text,
					item.warning_threshold
				]
		else:
			content += "%s\n" % item.text

	print("[DEBUG] Saved Searches Saved To Disk!")

	Cache.update_content("saved_searches", content, false)


func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if not $DebounceTimer.is_stopped():
			$DebounceTimer.stop()
			save_to_disk()
