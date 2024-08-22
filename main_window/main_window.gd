@tool
extends MarginContainer

@export var minimum_vertical_margin := 8:
	set(value):
		minimum_vertical_margin = value
		if is_inside_tree():
			add_theme_constant_override("margin_top", minimum_vertical_margin)
			add_theme_constant_override("margin_bottom", minimum_vertical_margin)



func _ready() -> void:
	if Engine.is_editor_hint():
		return

	get_window().min_size = Vector2i(
		# FIXME: get rid of those hardcoded values
		2 * 28 + 2 * 16 + 160, 2 * minimum_vertical_margin + 79 + 5 * 40
	)
	get_tree().get_root().size_changed.connect(_on_window_size_changed)


func _on_window_size_changed() -> void:
	if Engine.is_editor_hint():
		return

	var window_height := DisplayServer.window_get_size().y

	var todo_list_height := window_height - 2 * minimum_vertical_margin - 79
	var todo_item_height := 40

	var total_vertical_margin = 2 * minimum_vertical_margin + todo_list_height % todo_item_height
	add_theme_constant_override("margin_top", 0.5 * total_vertical_margin)
	add_theme_constant_override("margin_bottom", 0.5 * total_vertical_margin)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()

		if $Overlay.visible:
			$Overlay.close_overlay()
	elif event.is_action_pressed("toggle_fullscreen"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			_:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
