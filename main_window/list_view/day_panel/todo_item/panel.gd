extends PanelContainer


func _init() -> void:
	self_modulate = Color(randf(), randf(), randf())


func _get_drag_data(at_position: Vector2) -> Variant:
	var pivot = Control.new()

	var preview = self.duplicate()
	preview.self_modulate = self.self_modulate
	preview.modulate.a = 0.6
	preview.size = self.size
	preview.position = -at_position

	pivot.add_child(preview)
	set_drag_preview(pivot)

	return get_parent()
