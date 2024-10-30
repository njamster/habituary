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
		2 * 28 + 2 * 16 + 160,
		2 * minimum_vertical_margin + 28 + 16 + 61 + 5 * 40
	)
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	_on_window_size_changed()


func _on_window_size_changed() -> void:
	if Engine.is_editor_hint():
		return

	var window_height := DisplayServer.window_get_size().y

	var todo_list_height := window_height - 28 - 16 - 2 * minimum_vertical_margin - 81 - 8
	var todo_item_height := 40

	var total_vertical_margin = 2 * minimum_vertical_margin + todo_list_height % todo_item_height
	add_theme_constant_override("margin_top", floor(0.5 * total_vertical_margin))
	add_theme_constant_override("margin_bottom", ceil(0.5 * total_vertical_margin))
