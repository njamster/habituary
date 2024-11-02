@tool
extends MarginContainer

@export var minimum_vertical_margin := 12:
	set(value):
		minimum_vertical_margin = value
		add_theme_constant_override("margin_top", minimum_vertical_margin)
		add_theme_constant_override("margin_bottom", minimum_vertical_margin)


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	get_tree().root.size_changed.connect(_on_window_size_changed)
	_on_window_size_changed()


func _on_window_size_changed() -> void:
	const TODO_ITEM_HEIGHT := 40

	var todo_list_height := get_window().size.y - 28 - 16 - 2 * minimum_vertical_margin - 81 - 8

	var total_vertical_margin = 2 * minimum_vertical_margin + todo_list_height % TODO_ITEM_HEIGHT
	add_theme_constant_override("margin_top", floor(0.5 * total_vertical_margin))
	add_theme_constant_override("margin_bottom", ceil(0.5 * total_vertical_margin))
