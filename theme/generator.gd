@tool
extends EditorScript

# Colors from the popular "Nord" palette, see: https://www.nordtheme.com/

# neutral colors (from dark to light)
const NEUTRAL_1 := Color("#2E3440")
const NEUTRAL_2 := Color("#3B4252")
const NEUTRAL_3 := Color("#434C5E")
const NEUTRAL_4 := Color("#4C566A")
const NEUTRAL_5 := Color("#D8DEE9")
const NEUTRAL_6 := Color("#E5E9F0")
const NEUTRAL_7 := Color("#ECEFF4")
const NEUTRAL_8 := Color("#F5F5F5")  # NOTE: added by me, not officially part of the palette

# primary colors
const FROST_1 := Color("#8FBCBB")
const FROST_2 := Color("#88C0D0")  # NOTE: unused, so far
const FROST_3 := Color("#81A1C1")
const FROST_4 := Color("#5E81AC")

# secondary colors
const AURORA_1 := Color("#BF616A")  # NOTE: unused, so far
const AURORA_2 := Color("#D08770")  # NOTE: unused, so far
const AURORA_3 := Color("#EBCB8B")  # NOTE: unused, so far
const AURORA_4 := Color("#A3BE8C")
const AURORA_5 := Color("#B48EAD")  # NOTE: unused, so far


## This function will get called when this EditorScript is executed, clicking "File" > "Run" in the
## Script Editor, or pressing its associated keyboard shortcut (Ctrl + Shift + X, by default).
func _run():
	_create_theme("dark_theme",
		NEUTRAL_1,
		NEUTRAL_2,
		NEUTRAL_3,
		NEUTRAL_4,
		NEUTRAL_5,
		NEUTRAL_6,
		NEUTRAL_7,
		NEUTRAL_8,
		FROST_1,
		FROST_2,
		FROST_3,
		FROST_4,
		AURORA_1,
		AURORA_2,
		AURORA_3,
		AURORA_4,
		AURORA_5,
	)

	_create_theme("light_theme",
		NEUTRAL_8,
		NEUTRAL_7,
		NEUTRAL_6,
		NEUTRAL_5,
		NEUTRAL_4,
		NEUTRAL_3,
		NEUTRAL_2,
		NEUTRAL_1,
		FROST_1,
		FROST_2,
		FROST_3,
		FROST_4,
		AURORA_1,
		AURORA_2,
		AURORA_3,
		AURORA_4,
		AURORA_5,
	)


func _create_theme(file_name : String, neutral_1 : Color, neutral_2 : Color, neutral_3 : Color,
neutral_4 : Color, neutral_5 : Color, neutral_6 : Color, neutral_7 : Color, neutral_8 : Color,
primary_1 : Color, primary_2 : Color, primary_3 : Color, primary_4 : Color, secondary_1 : Color,
secondary_2 : Color, secondary_3 : Color, secondary_4 : Color, secondary_5 : Color) -> void:
	var base_dir : String = get_script().get_path().get_base_dir()
	var file_path := base_dir.path_join(file_name) + ".tres"

	var theme := ConciseTheme.new()

	#region AcceptDialog
	theme.start_type_definition("AcceptDialog")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_1,
		"corner_radius" = 3,
		"content_margin" = 8,
	})
	#endregion

	#region Bookmark_Today
	theme.start_type_definition("Bookmark_Today", "PanelContainer")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_1,
		"border_width" = 3,
		"border_color" = Color(secondary_4, 0.75),
		"border_blend" = true,
		"corner_radius" = 6,
		"content_margin" = 12,
	})
	#endregion

	#region Button
	theme.start_type_definition("Button")

	theme.font_color = neutral_6
	theme.font_disabled_color = Color(neutral_6, 0.5)
	theme.font_focus_color = neutral_6
	theme.font_hover_color = neutral_6
	theme.font_hover_pressed_color = neutral_6
	theme.font_pressed_color = neutral_6

	theme.icon_disabled_color = Color(neutral_6, 0.5)
	theme.icon_focus_color = neutral_6
	theme.icon_hover_color = neutral_6
	theme.icon_hover_pressed_color = neutral_6
	theme.icon_normal_color = neutral_6
	theme.icon_pressed_color = neutral_6

	theme.focus = _create_style_box_flat({
		"bg_color" = neutral_6,
		"draw_center" = false,
		"border_width" = 2,
		"corner_radius" = 3,
		"expand_margin" = 2,
		"content_margin" = 4,
	})
	theme.hover = _create_style_box_flat({
		"bg_color" = neutral_1,
		"corner_radius" = 3,
		"content_margin" = 4,
	})
	theme.normal = _create_style_box_flat({
		"bg_color" = neutral_2,
		"corner_radius" = 3,
		"content_margin" = 4,
	})
	theme.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 3,
		"content_margin" = 4,
	})
	#endregion

	#region CalendarWidget_Button
	theme.start_type_definition("CalendarWidget_Button", "Button")

	theme.font_color = neutral_7

	theme.icon_normal_color = neutral_7
	theme.icon_disabled_color = Color(neutral_7, 0.3)

	theme.disabled = _create_style_box_flat({
		"bg_color" = Color(neutral_4, 0.3),
		"corner_radius" = 4,
		"content_margin" = 4,
	})
	theme.hover = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 4,
		"content_margin" = 4,
	})
	theme.normal = _create_style_box_flat({
		"bg_color" = neutral_4,
		"corner_radius" = 4,
		"content_margin" = 4,
	})
	theme.pressed = _create_style_box_flat({
		"bg_color" = neutral_4,
		"corner_radius" = 4,
		"content_margin" = 4,
	})
	#endregion

	#region CalendarWidget_DayButton
	theme.start_type_definition("CalendarWidget_DayButton", "Button")

	theme.font_color = neutral_7
	theme.font_hover_color = neutral_7

	theme.font_size = 14

	theme.hover = _create_style_box_flat({
		"bg_color" = neutral_3,
		"corner_radius" = 45,
	})
	theme.normal = _create_style_box_flat({
		"draw_center" = false,
		"corner_radius" = 45,
	})
	theme.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	#endregion

	#region CalendarWidget_DayButton_Selected
	theme.start_type_definition("CalendarWidget_DayButton_Selected", "Button")

	theme.font_color = neutral_7
	theme.font_hover_color = neutral_1

	theme.font_size = 14

	theme.hover = _create_style_box_flat({
		"bg_color" = neutral_5,
		"corner_radius" = 45,
	})
	theme.normal = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	theme.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	#endregion

	#region CalendarWidget_DayButton_Today
	theme.start_type_definition("CalendarWidget_DayButton_Today", "Button")

	theme.font_color = neutral_7
	theme.font_hover_color = neutral_1

	theme.font_size = 14

	theme.hover = _create_style_box_flat({
		"bg_color" = neutral_5,
		"corner_radius" = 45,
	})
	theme.normal = _create_style_box_flat({
		"bg_color" = Color(primary_1, 0.4),
		"corner_radius" = 45,
	})
	theme.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	#endregion

	#region CalendarWidget_DayButton_WeekendDay
	theme.start_type_definition("CalendarWidget_DayButton_WeekendDay", "Button")

	theme.font_color = primary_4

	theme.font_size = 14

	theme.hover = _create_style_box_flat({
		"bg_color" = primary_4,
		"corner_radius" = 45,
	})
	theme.normal = _create_style_box_flat({
		"draw_center" = false,
		"corner_radius" = 45,
	})
	theme.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	#endregion

	#region CheckButton
	theme.start_type_definition("CheckButton")

	theme.font_color = neutral_7
	theme.font_hover_color = neutral_7
	theme.font_pressed_color = neutral_7
	theme.font_hover_pressed_color = neutral_7

	theme.disabled = StyleBoxEmpty.new()
	theme.focus = StyleBoxEmpty.new()
	theme.hover = StyleBoxEmpty.new()
	theme.hover_pressed = StyleBoxEmpty.new()
	theme.normal = StyleBoxEmpty.new()
	theme.pressed = StyleBoxEmpty.new()
	#endregion

	#region Label
	theme.start_type_definition("Label")

	theme.font_color = neutral_6
	#endregion

	#region Label_WeekendDay
	theme.start_type_definition("Label_WeekendDay", "Label")

	theme.font_color = primary_4
	#endregion

	#region LeftSidebarButton
	theme.start_type_definition("LeftSidebarButton", "Button")

	theme.font_color = neutral_7

	theme.icon_normal_color = neutral_7

	theme.disabled = _create_style_box_flat({
		"bg_color" = Color(neutral_3, 0.3),
		"corner_radius" = [0, 4, 4, 0],
		"content_margin" = 4,
	})
	theme.focus = _create_style_box_flat({
		"draw_center" = false,
		"border_width" = [0, 2, 2, 2],
		"corner_radius" = [0, 4, 4, 0],
		"expand_margin" = [0, 2, 2, 2],
		"content_margin" = 4,
	})
	theme.hover = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = [0, 4, 4, 0],
		"content_margin" = 4,
	})
	theme.normal = _create_style_box_flat({
		"bg_color" = neutral_3,
		"corner_radius" = [0, 4, 4, 0],
		"content_margin" = 4,
	})
	theme.pressed = _create_style_box_flat({
		"bg_color" = primary_4,
		"corner_radius" = [0, 4, 4, 0],
		"content_margin" = 4,
	})
	#endregion

	#region LineEdit
	theme.start_type_definition("LineEdit")

	theme.caret_color = primary_3

	theme.font_color = neutral_7
	theme.font_placeholder_color = Color(neutral_7, 0.6)
	#endregion

	#region PanelContainer
	theme.start_type_definition("PanelContainer")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_1,
		"corner_radius" = 6,
		"content_margin" = 12,
	})
	#endregion

	#region PanelContainer_Popup
	theme.start_type_definition("PanelContainer_Popup", "PanelContainer")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_2,
		"corner_radius" = 6,
		"content_margin" = 12,
	})
	#endregion

	#region RichTextLabel
	theme.start_type_definition("RichTextLabel")

	theme.default_color = neutral_7
	#endregion

	#region RightSidebarButton
	theme.start_type_definition("RightSidebarButton", "Button")

	theme.font_color = neutral_7

	theme.icon_normal_color = neutral_7

	theme.disabled = _create_style_box_flat({
		"bg_color" = Color(neutral_3, 0.3),
		"corner_radius" = [4, 0, 0, 4],
		"content_margin" = 4,
	})
	theme.focus = _create_style_box_flat({
		"draw_center" = false,
		"border_width" = [2, 2, 0, 2],
		"corner_radius" = [4, 0, 0, 4],
		"expand_margin" = [2, 2, 0, 2],
		"content_margin" = 4,
	})
	theme.hover = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = [4, 0, 0, 4],
		"content_margin" = 4,
	})
	theme.normal = _create_style_box_flat({
		"bg_color" = neutral_3,
		"corner_radius" = [4, 0, 0, 4],
		"content_margin" = 4,
	})
	theme.pressed = _create_style_box_flat({
		"bg_color" = primary_4,
		"corner_radius" = [4, 0, 0, 4],
		"content_margin" = 4,
	})
	#endregion

	#region SearchBar
	theme.start_type_definition("SearchBar", "PanelContainer")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_2,
		"corner_radius" = 5,
		"content_margin" = [8, 4, 8, 4],
	})
	#endregion

	#region SearchBar_Focused
	theme.start_type_definition("SearchBar_Focused", "PanelContainer")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_3,
		"border_width" = 2,
		"border_color" = primary_4,
		"corner_radius" = 5,
		"content_margin" = [8, 4, 8, 4],
	})
	#endregion

	#region SearchBar_Hover
	theme.start_type_definition("SearchBar_Hover", "PanelContainer")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_3,
		"border_width" = 1,
		"border_color" = neutral_5,
		"corner_radius" = 5,
		"content_margin" = [8, 4, 8, 4],
	})
	#endregion

	#region SidePanel
	theme.start_type_definition("SidePanel", "PanelContainer")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_3,
		"border_width" = [0, 0, 4, 0],
		"border_color" = primary_4,
		"content_margin" = [8, 8, 12, 8],
	})
	#endregion

	#region SpinBox
	# theme.start_type_definition("SpinBox")
	# ...
	# NOTE: Cannot be themed properly yet! See: https://github.com/godotengine/godot/pull/89265
	# FIXME: Wait for Godot 4.4
	#endregion

	#region SubtleLabel
	theme.start_type_definition("SubtleLabel", "Label")

	theme.font_color = neutral_5
	#endregion

	#region TooltipLabel
	theme.start_type_definition("TooltipLabel")

	theme.font_size = 13
	#endregion

	#region TooltipPanel
	theme.start_type_definition("TooltipPanel", "PanelContainer")

	theme.panel = _create_style_box_flat({
		"bg_color" = neutral_4,
		"corner_radius" = 5,
		"content_margin" = [6, 2, 6, 2],
	})
	#endregion

	# NOTE: Inspecting updated themes in Godot won't show the most recent version, see:
	#   https://github.com/godotengine/godot/issues/30302
	# If that is required, reload the project via "Project" -> "Reload Current Project".
	ResourceSaver.save(theme, file_path)


func _create_style_box_flat(properties : Dictionary) -> StyleBoxFlat:
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
			"expand_margin":
				if value is int:
					style_box.set_expand_margin_all(value)
				elif value is Array:
					style_box.expand_margin_left = value[0]
					style_box.expand_margin_top = value[1]
					style_box.expand_margin_right = value[2]
					style_box.expand_margin_bottom = value[3]
			"content_margin":
				if value is int:
					style_box.set_content_margin_all(value)
				elif value is Array:
					style_box.content_margin_left = value[0]
					style_box.content_margin_top = value[1]
					style_box.content_margin_right = value[2]
					style_box.content_margin_bottom = value[3]

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

	return style_box
