extends Theme
class_name ConciseTheme

const DISTINCT_LINE_PROPERTIES := [
	"color",
	"grow_begin",
	"grow_end",
	"thickness",
	"vertical"
]

const DISTINCT_TEXTURE_PROPERTIES := [
	"texture",
	"texture_margin_left",
	"texture_margin_top",
	"texture_margin_right",
	"texture_margin_bottom",
	"axis_stretch_horizontal",
	"axis_stretch_vertical",
	"region_rect",
	"modulate_color"
]

const DISTINCT_FLAT_PROPERTIES := [
	"bg_color",
	"skew",
	"corner_detail",
	"border_width_left",
	"border_width_top",
	"border_width_right",
	"border_width_bottom",
	"border_color",
	"border_blend",
	"corner_radius_top_left",
	"corner_radius_top_right",
	"corner_radius_bottom_right",
	"corner_radius_bottom_left",
	"shadow_color",
	"shadow_size",
	"shadow_offset",
	"anti_aliasing",
	"anti_aliasing_size",
]


func create_theme_type(theme_type: StringName, base_type: StringName = "") -> ThemeType:
	return ThemeType.new(self, theme_type, base_type)


func _update_style_box(name : StringName, theme_type : StringName, properties : Dictionary) -> void:
	var style_box : StyleBox
	if self.has_stylebox(name, theme_type):
		style_box = self.get_stylebox(name, theme_type)
	else:
		style_box = _deduce_style_box_type(properties)

	for key in properties:
		var value = properties[key]

		match key:
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
			_:
				if style_box.get(key) != null:
					style_box[key] = properties[key]
				else:
					push_warning(
						"Unknown %s property '%s' – will be ignored!" % [style_box.get_class(), key]
					)

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

	self.set_stylebox(name, theme_type, style_box)


func _deduce_style_box_type(properties : Dictionary) -> StyleBox:
	var is_empty := true

	for key in properties:
		if key in DISTINCT_LINE_PROPERTIES:
			return StyleBoxLine.new()
		elif key in DISTINCT_TEXTURE_PROPERTIES:
			return StyleBoxTexture.new()
		elif key in DISTINCT_FLAT_PROPERTIES:
			return StyleBoxFlat.new()
		elif is_empty and not key.begins_with("content_margin"):
			is_empty = false

	if is_empty:
		return StyleBoxEmpty.new()
	else:
		return StyleBoxFlat.new()


class ThemeType:
	var _theme_type : StringName
	var _base_type : StringName
	var _theme : Theme


	func _init(theme: Theme, theme_type: StringName, base_type: StringName):
		theme.add_type(theme_type)
		if base_type:
			theme.set_type_variation(theme_type, base_type)

		self._theme_type = theme_type
		self._base_type = base_type
		self._theme = theme


	func _set(property: StringName, value: Variant) -> bool:
		if value is Color:
			self._theme.set_color(property, self._theme_type, value)
		elif value is Dictionary:
			self._theme._update_style_box(property, self._theme_type, value)
		elif value is int:
			if property == "font_size":
				self._theme.set_font_size(property, self._theme_type, value)
			else:
				self._theme.set_constant(property, self._theme_type, value)
		elif value is Font:
			self._theme.set_font(property, self._theme_type, value)
		elif value is Texture2D:
			self._theme.set_icon(property, self._theme_type, value)
		elif value is StyleBox:
			self._theme.set_stylebox(property, self._theme_type, value)
		else:
			return false

		return true


	func set_default_color(color : Color) -> void:
		var default_theme := ThemeDB.get_default_theme()

		if self._base_type:
			for name in default_theme.get_color_list(self._base_type):
				self._theme.set_color(name, self._theme_type, color)
		else:
			for name in default_theme.get_color_list(self._theme_type):
				self._theme.set_color(name, self._theme_type, color)


	func set_main_style(properties : Dictionary) -> void:
		var default_theme := ThemeDB.get_default_theme()

		if self._base_type:
			for name in default_theme.get_stylebox_list(self._base_type):
				self._theme._update_style_box(name, self._theme_type, properties)
		else:
			for name in default_theme.get_stylebox_list(self._theme_type):
				self._theme._update_style_box(name, self._theme_type, properties)
