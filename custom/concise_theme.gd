extends Theme
class_name ConciseTheme


func create_theme_type(theme_type: StringName, base_type: StringName = "") -> ThemeType:
	return ThemeType.new(self, theme_type, base_type)


class ThemeType:
	var name : StringName
	var _theme : Theme


	func _init(theme: Theme, theme_type: StringName, base_type: StringName):
		theme.add_type(theme_type)
		if base_type:
			theme.set_type_variation(theme_type, base_type)

		self.name = theme_type
		self._theme = theme


	func _set(property: StringName, value: Variant) -> bool:
		if value is Color:
			_theme.set_color(property, name, value)
			return true
		elif value is int:
			if property == "font_size":
				_theme.set_font_size(property, name, value)
				return true
			else:
				_theme.set_constant(property, name, value)
				return true
		elif value is Font:
			_theme.set_font(property, name, value)
			return true
		elif value is Texture2D:
			_theme.set_icon(property, name, value)
			return true
		elif value is StyleBox:
			_theme.set_stylebox(property, name, value)
			return true

		return false
