extends LineEdit


func _ready() -> void:
	_on_window_size_changed()
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	EventBus.view_mode_changed.connect(func(_view_mode): _on_window_size_changed())


func _on_window_size_changed() -> void:
	# get the relevant nodes
	# FIXME: avoid hardcoding the node paths
	var list_view = get_node("/root/MainWindow/HBox/ListView/")
	var search_button = get_node("/root/MainWindow/HBox/ToolbarLeft/ExtraPanelsWidget/SearchScreen")

	# wait till the relevant nodes get resized
	await get_tree().process_frame
	await get_tree().process_frame

	# FIXME: avoid hardcoded values
	size.x = 16 + list_view.get_child(0).size.x
	global_position.y = 2 + search_button.global_position.y


func _on_text_changed(new_text: String) -> void:
	EventBus.search_query_changed.emit(new_text)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		EventBus.search_query_changed.emit("")
		get_parent().close_overlay()
