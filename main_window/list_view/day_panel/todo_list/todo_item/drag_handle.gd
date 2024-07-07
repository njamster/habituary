extends TextureRect

const DRAGGED := preload("resources/dragged.tres")

@onready var host := get_parent().get_parent().get_parent()


func _get_drag_data(_at_position: Vector2) -> Variant:
	if host.done:
		return

	var pivot = Control.new()

	var preview = host.duplicate()
	if not preview.is_heading:
		preview.add_theme_stylebox_override("panel", DRAGGED)
	preview.self_modulate = host.self_modulate
	preview.size = host.size
	preview.position = -get_parent().position - position - 0.5 * size
	pivot.add_child(preview)
	set_drag_preview(pivot)

	preview.get_node("HBox/UI/Delete").hide()
	preview.get_node("HBox/UI").show()
	host.modulate.a = 0.6

	return host
