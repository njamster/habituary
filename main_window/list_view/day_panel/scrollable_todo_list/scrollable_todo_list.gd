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

	%TodoList.list_save_requested.connect(save_to_disk)
	#endregion


func save_to_disk() -> void:
	if not %TodoList.pending_save:
		return # early

	if %TodoList/Items.get_child_count():
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
