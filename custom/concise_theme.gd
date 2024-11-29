extends Theme
class_name ConciseTheme

var most_recent_type : StringName


func start_type_definition(theme_type: StringName, base_type: StringName = "") -> void:
	self.add_type(theme_type)
	if base_type:
		self.set_type_variation(theme_type, base_type)
	most_recent_type = theme_type


func _set(property: StringName, value: Variant) -> bool:
	if not most_recent_type:
		push_error("Invalid property assignment! Make sure to call 'add_type' or 'add_type_variation' first.")
		return true

	if value is Color:
		self.set_color(property, most_recent_type, value)
		return true

	return false
