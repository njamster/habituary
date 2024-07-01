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

	DisplayServer.window_set_min_size(Vector2i.ZERO) # FIXME
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
