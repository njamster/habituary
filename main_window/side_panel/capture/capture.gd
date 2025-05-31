extends VBoxContainer


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	%ScrollableTodoList.store_path = Settings.store_path.path_join("capture.txt")
	_on_window_size_changed()


func _connect_signals() -> void:
	#region Global Signals
	get_tree().root.size_changed.connect(_on_window_size_changed)
	#endregion


func _on_window_size_changed() -> void:
	# Mirror the MainPanel's bottom margin (minus an offset factor, considering
	# the SidePanel holding the Capture has a bottom margin on its own!)
	$OuterMargin.add_theme_constant_override(
		"margin_bottom",
		get_node("/root/MainWindow/HBox/MainPanel")["theme_override_constants/margin_bottom"] - \
			get_theme_stylebox("panel", "SidePanel").content_margin_bottom
	)

	var remaining_space := int(
		get_window().size.y - \
		get_theme_stylebox("panel", "SidePanel").content_margin_top - \
		$Heading.size.y - \
		get_theme_constant("separation", theme_type_variation) - \
		$Label.size.y - \
		get_theme_constant("separation", theme_type_variation) - \
		$OuterMargin["theme_override_constants/margin_bottom"] - \
		get_theme_stylebox("panel", "SidePanel").content_margin_bottom - \
		7  # No idea what I missed, but it appears to be 7 pixel high...
	)

	$OuterMargin.add_theme_constant_override(
		"margin_top",
		remaining_space % %ScrollableTodoList/ScrollContainer.TODO_ITEM_HEIGHT
	)
