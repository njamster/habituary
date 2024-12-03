extends Theme
class_name ConciseTheme


func create_theme_type(theme_type: StringName, base_type: StringName = "") -> ThemeType:
	return ThemeType.new(self, theme_type, base_type)


func create_style_box_flat(properties : Dictionary) -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()

	for key in properties:
		var value = properties[key]

		match key:
			"bg_color":
				if value is Color:
					style_box.bg_color = value
			"draw_center":
				if value is bool:
					style_box.draw_center = value
			"corner_detail":
				if value is int:
					style_box.corner_detail = value
			"border_width":
				if value is int:
					style_box.set_border_width_all(value)
				elif value is Array:
					style_box.border_width_left = value[0]
					style_box.border_width_top = value[1]
					style_box.border_width_right = value[2]
					style_box.border_width_bottom = value[3]
				elif value is Dictionary:
					style_box.border_width_left = value.left
					style_box.border_width_top = value.top
					style_box.border_width_right = value.right
					style_box.border_width_bottom = value.bottom
			"border_color":
				if value is Color:
					style_box.border_color = value
			"border_blend":
				if value is bool:
					style_box.border_blend = value
			"corner_radius":
				if value is int:
					style_box.set_corner_radius_all(value)
				elif value is Array:
					style_box.corner_radius_top_left = value[0]
					style_box.corner_radius_top_right = value[1]
					style_box.corner_radius_bottom_right = value[2]
					style_box.corner_radius_bottom_left = value[3]
				elif value is Dictionary:
					style_box.corner_radius_top_left = value.top_left
					style_box.corner_radius_top_right = value.top_right
					style_box.corner_radius_bottom_right = value.bottom_right
					style_box.corner_radius_bottom_left = value.bottom_left
			"expand_margin":
				if value is int:
					style_box.set_expand_margin_all(value)
				elif value is Array:
					style_box.expand_margin_left = value[0]
					style_box.expand_margin_top = value[1]
					style_box.expand_margin_right = value[2]
					style_box.expand_margin_bottom = value[3]
				elif value is Dictionary:
					style_box.expand_margin_left = value.left
					style_box.expand_margin_top = value.top
					style_box.expand_margin_right = value.right
					style_box.expand_margin_bottom = value.bottom
			"content_margin":
				if value is int:
					style_box.set_content_margin_all(value)
				elif value is Array:
					style_box.content_margin_left = value[0]
					style_box.content_margin_top = value[1]
					style_box.content_margin_right = value[2]
					style_box.content_margin_bottom = value[3]
				elif value is Dictionary:
					style_box.content_margin_left = value.left
					style_box.content_margin_top = value.top
					style_box.content_margin_right = value.right
					style_box.content_margin_bottom = value.bottom

	# Unless it's manually set to a different value, automatically set the value of `corner_detail`
	# relative to the StyleBox' maximum `corner_radius` (as recommended in Godot's documentation).
	if not properties.has("corner_detail"):
		var max_corner_radius : int = max(
			style_box.corner_radius_top_left,
			style_box.corner_radius_top_right,
			style_box.corner_radius_bottom_right,
			style_box.corner_radius_bottom_left
		)

		if max_corner_radius < 10:
			style_box.corner_detail = 5
		elif max_corner_radius < 30:
			style_box.corner_detail = 12
		else:
			pass # TODO: Which value to use then?

	return style_box


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
		elif value is Dictionary:
			var stylebox : StyleBoxFlat = _theme.create_style_box_flat(value)
			_theme.set_stylebox(property, name, stylebox)
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
