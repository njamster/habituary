extends VBoxContainer


var store_path: String:
	set(value):
		if store_path:  # once set, store_path becomes immutable
			return

		store_path = value
		load_from_disk()

var is_dragged := false


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Local Signals
	# NOTE: `tree_exited` will be emitted both when this panel is removed from the tree because
	# the user scrolled the list's view, as well as on a NOTIFICATION_WM_CLOSE_REQUEST.
	tree_exited.connect(save_to_disk)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	%ScrollContainer.gui_input.connect(_on_gui_input)

	%TodoList.list_save_requested.connect(save_to_disk)
	#endregion


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return %TodoList._can_drop_data(_at_position, data)


func _drop_data(at_position: Vector2, data: Variant) -> void:
	%TodoList._drop_data(at_position - %ScrollContainer.position, data)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		if event.pressed:
			%TodoList.add_todo(%TodoList/Offset/LineHighlight.global_position)


func save_to_disk() -> void:
	if not %TodoList.pending_save:
		return # early

	if %TodoList.has_items():
		var file := FileAccess.open(store_path, FileAccess.WRITE)
		%TodoList.save_to_disk(file)
	elif FileAccess.file_exists(store_path):
		DirAccess.remove_absolute(store_path)

	%TodoList.pending_save = false
	if OS.is_debug_build():
		# NOTE: This will *not* be printed when this function is called after `tree_exited` was
		# emitted. See: https://github.com/godotengine/godot/issues/90667
		print("[DEBUG] List Saved to Disk!")


func load_from_disk() -> void:
	if FileAccess.file_exists(store_path):
		%TodoList.load_from_disk(FileAccess.open(store_path, FileAccess.READ))


func _on_mouse_entered() -> void:
	$HoverTimer.timeout.connect(%TodoList.show_line_highlight.bind(get_global_mouse_position()))
	$HoverTimer.start()


func _on_mouse_exited() -> void:
	if $HoverTimer.is_stopped():
		%TodoList.hide_line_highlight()
	else:
		$HoverTimer.stop()
	$HoverTimer.timeout.disconnect(%TodoList.show_line_highlight)
