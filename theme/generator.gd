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
	var accept_dialog := theme.create_theme_type("AcceptDialog")

	accept_dialog.panel = _create_style_box_flat({
		"bg_color" = neutral_1,
		"corner_radius" = 3,
		"content_margin" = 8,
	})
	#endregion

	#region Bookmark_Today
	var bookmark_today := theme.create_theme_type("Bookmark_Today", "PanelContainer")

	bookmark_today.panel = _create_style_box_flat({
		"bg_color" = neutral_1,
		"border_width" = 3,
		"border_color" = Color(secondary_4, 0.75),
		"border_blend" = true,
		"corner_radius" = 6,
		"content_margin" = 12,
	})
	#endregion

	#region Button
	var button := theme.create_theme_type("Button")

	button.font_color = neutral_6
	button.font_disabled_color = Color(neutral_6, 0.5)
	button.font_focus_color = neutral_6
	button.font_hover_color = neutral_6
	button.font_hover_pressed_color = neutral_6
	button.font_pressed_color = neutral_6

	button.icon_disabled_color = Color(neutral_6, 0.5)
	button.icon_focus_color = neutral_6
	button.icon_hover_color = neutral_6
	button.icon_hover_pressed_color = neutral_6
	button.icon_normal_color = neutral_6
	button.icon_pressed_color = neutral_6

	button.focus = _create_style_box_flat({
		"bg_color" = neutral_6,
		"draw_center" = false,
		"border_width" = 2,
		"corner_radius" = 3,
		"expand_margin" = 2,
		"content_margin" = 4,
	})
	button.hover = _create_style_box_flat({
		"bg_color" = neutral_1,
		"corner_radius" = 3,
		"content_margin" = 4,
	})
	button.normal = _create_style_box_flat({
		"bg_color" = neutral_2,
		"corner_radius" = 3,
		"content_margin" = 4,
	})
	button.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 3,
		"content_margin" = 4,
	})
	#endregion

	#region CalendarWidget_Button
	var calendar_widget_button := theme.create_theme_type("CalendarWidget_Button", "Button")

	calendar_widget_button.font_color = neutral_7

	calendar_widget_button.icon_normal_color = neutral_7
	calendar_widget_button.icon_disabled_color = Color(neutral_7, 0.3)

	calendar_widget_button.disabled = _create_style_box_flat({
		"bg_color" = Color(neutral_4, 0.3),
		"corner_radius" = 4,
		"content_margin" = 4,
	})
	calendar_widget_button.hover = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 4,
		"content_margin" = 4,
	})
	calendar_widget_button.normal = _create_style_box_flat({
		"bg_color" = neutral_4,
		"corner_radius" = 4,
		"content_margin" = 4,
	})
	calendar_widget_button.pressed = _create_style_box_flat({
		"bg_color" = neutral_4,
		"corner_radius" = 4,
		"content_margin" = 4,
	})
	#endregion

	#region CalendarWidget_DayButton
	var calendar_widget_day_button := theme.create_theme_type("CalendarWidget_DayButton", "Button")

	calendar_widget_day_button.font_color = neutral_7
	calendar_widget_day_button.font_hover_color = neutral_7

	calendar_widget_day_button.font_size = 14

	calendar_widget_day_button.hover = _create_style_box_flat({
		"bg_color" = neutral_3,
		"corner_radius" = 45,
	})
	calendar_widget_day_button.normal = _create_style_box_flat({
		"draw_center" = false,
		"corner_radius" = 45,
	})
	calendar_widget_day_button.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	#endregion

	#region CalendarWidget_DayButton_Selected
	var calendar_widget_day_button_selected := theme.create_theme_type("CalendarWidget_DayButton_Selected", "Button")

	calendar_widget_day_button_selected.font_color = neutral_7
	calendar_widget_day_button_selected.font_hover_color = neutral_1

	calendar_widget_day_button_selected.font_size = 14

	calendar_widget_day_button_selected.hover = _create_style_box_flat({
		"bg_color" = neutral_5,
		"corner_radius" = 45,
	})
	calendar_widget_day_button_selected.normal = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	calendar_widget_day_button_selected.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	#endregion

	#region CalendarWidget_DayButton_Today
	var calendar_widget_day_button_today := theme.create_theme_type("CalendarWidget_DayButton_Today", "Button")

	calendar_widget_day_button_today.font_color = neutral_7
	calendar_widget_day_button_today.font_hover_color = neutral_1

	calendar_widget_day_button_today.font_size = 14

	calendar_widget_day_button_today.hover = _create_style_box_flat({
		"bg_color" = neutral_5,
		"corner_radius" = 45,
	})
	calendar_widget_day_button_today.normal = _create_style_box_flat({
		"bg_color" = Color(primary_1, 0.4),
		"corner_radius" = 45,
	})
	calendar_widget_day_button_today.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	#endregion

	#region CalendarWidget_DayButton_WeekendDay
	var calendar_widget_day_button_weekend_day := theme.create_theme_type("CalendarWidget_DayButton_WeekendDay", "Button")

	calendar_widget_day_button_weekend_day.font_color = primary_4

	calendar_widget_day_button_weekend_day.font_size = 14

	calendar_widget_day_button_weekend_day.hover = _create_style_box_flat({
		"bg_color" = primary_4,
		"corner_radius" = 45,
	})
	calendar_widget_day_button_weekend_day.normal = _create_style_box_flat({
		"draw_center" = false,
		"corner_radius" = 45,
	})
	calendar_widget_day_button_weekend_day.pressed = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = 45,
	})
	#endregion

	#region CheckButton
	var check_button := theme.create_theme_type("CheckButton")

	check_button.font_color = neutral_7
	check_button.font_hover_color = neutral_7
	check_button.font_pressed_color = neutral_7
	check_button.font_hover_pressed_color = neutral_7

	check_button.disabled = StyleBoxEmpty.new()
	check_button.focus = StyleBoxEmpty.new()
	check_button.hover = StyleBoxEmpty.new()
	check_button.hover_pressed = StyleBoxEmpty.new()
	check_button.normal = StyleBoxEmpty.new()
	check_button.pressed = StyleBoxEmpty.new()
	#endregion

	#region Label
	var label := theme.create_theme_type("Label")

	label.font_color = neutral_6
	#endregion

	#region Label_WeekendDay
	var label_weekend_day := theme.create_theme_type("Label_WeekendDay", "Label")

	label_weekend_day.font_color = primary_4
	#endregion

	#region LeftSidebarButton
	var left_sidebar_button := theme.create_theme_type("LeftSidebarButton", "Button")

	left_sidebar_button.font_color = neutral_7

	left_sidebar_button.icon_normal_color = neutral_7

	left_sidebar_button.disabled = _create_style_box_flat({
		"bg_color" = Color(neutral_3, 0.3),
		"corner_radius" = [0, 4, 4, 0],
		"content_margin" = 4,
	})
	left_sidebar_button.focus = _create_style_box_flat({
		"draw_center" = false,
		"border_width" = [0, 2, 2, 2],
		"corner_radius" = [0, 4, 4, 0],
		"expand_margin" = [0, 2, 2, 2],
		"content_margin" = 4,
	})
	left_sidebar_button.hover = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = [0, 4, 4, 0],
		"content_margin" = 4,
	})
	left_sidebar_button.normal = _create_style_box_flat({
		"bg_color" = neutral_3,
		"corner_radius" = [0, 4, 4, 0],
		"content_margin" = 4,
	})
	left_sidebar_button.pressed = _create_style_box_flat({
		"bg_color" = primary_4,
		"corner_radius" = [0, 4, 4, 0],
		"content_margin" = 4,
	})
	#endregion

	#region LineEdit
	var line_edit := theme.create_theme_type("LineEdit")

	line_edit.caret_color = primary_3

	line_edit.font_color = neutral_7
	line_edit.font_placeholder_color = Color(neutral_7, 0.6)
	#endregion

	#region PanelContainer
	var panel_container := theme.create_theme_type("PanelContainer")

	panel_container.panel = _create_style_box_flat({
		"bg_color" = neutral_1,
		"corner_radius" = 6,
		"content_margin" = 12,
	})
	#endregion

	#region PanelContainer_Popup
	var panel_container_popup := theme.create_theme_type("PanelContainer_Popup", "PanelContainer")

	panel_container_popup.panel = _create_style_box_flat({
		"bg_color" = neutral_2,
		"corner_radius" = 6,
		"content_margin" = 12,
	})
	#endregion

	#region RichTextLabel
	var rich_text_label := theme.create_theme_type("RichTextLabel")

	rich_text_label.default_color = neutral_7
	#endregion

	#region RightSidebarButton
	var right_sidebar_button := theme.create_theme_type("RightSidebarButton", "Button")

	right_sidebar_button.font_color = neutral_7

	right_sidebar_button.icon_normal_color = neutral_7

	right_sidebar_button.disabled = _create_style_box_flat({
		"bg_color" = Color(neutral_3, 0.3),
		"corner_radius" = [4, 0, 0, 4],
		"content_margin" = 4,
	})
	right_sidebar_button.focus = _create_style_box_flat({
		"draw_center" = false,
		"border_width" = [2, 2, 0, 2],
		"corner_radius" = [4, 0, 0, 4],
		"expand_margin" = [2, 2, 0, 2],
		"content_margin" = 4,
	})
	right_sidebar_button.hover = _create_style_box_flat({
		"bg_color" = primary_3,
		"corner_radius" = [4, 0, 0, 4],
		"content_margin" = 4,
	})
	right_sidebar_button.normal = _create_style_box_flat({
		"bg_color" = neutral_3,
		"corner_radius" = [4, 0, 0, 4],
		"content_margin" = 4,
	})
	right_sidebar_button.pressed = _create_style_box_flat({
		"bg_color" = primary_4,
		"corner_radius" = [4, 0, 0, 4],
		"content_margin" = 4,
	})
	#endregion

	#region SearchBar
	var search_bar := theme.create_theme_type("SearchBar", "PanelContainer")

	search_bar.panel = _create_style_box_flat({
		"bg_color" = neutral_2,
		"corner_radius" = 5,
		"content_margin" = [8, 4, 8, 4],
	})
	#endregion

	#region SearchBar_Focused
	var search_bar_focused := theme.create_theme_type("SearchBar_Focused", "PanelContainer")

	search_bar_focused.panel = _create_style_box_flat({
		"bg_color" = neutral_3,
		"border_width" = 2,
		"border_color" = primary_4,
		"corner_radius" = 5,
		"content_margin" = [8, 4, 8, 4],
	})
	#endregion

	#region SearchBar_Hover
	var search_bar_hover := theme.create_theme_type("SearchBar_Hover", "PanelContainer")

	search_bar_hover.panel = _create_style_box_flat({
		"bg_color" = neutral_3,
		"border_width" = 1,
		"border_color" = neutral_5,
		"corner_radius" = 5,
		"content_margin" = [8, 4, 8, 4],
	})
	#endregion

	#region SidePanel
	var side_panel := theme.create_theme_type("SidePanel", "PanelContainer")

	side_panel.panel = _create_style_box_flat({
		"bg_color" = neutral_3,
		"border_width" = [0, 0, 4, 0],
		"border_color" = primary_4,
		"content_margin" = [8, 8, 12, 8],
	})
	#endregion

	#region SpinBox
	# var spin_box := theme.create_theme_type("SpinBox")
	# ...
	# NOTE: Cannot be themed properly yet! See: https://github.com/godotengine/godot/pull/89265
	# FIXME: Wait for Godot 4.4
	#endregion

	#region SubtleLabel
	var subtle_label := theme.create_theme_type("SubtleLabel", "Label")

	subtle_label.font_color = neutral_5
	#endregion

	#region TooltipLabel
	var tooltip_label := theme.create_theme_type("TooltipLabel")

	tooltip_label.font_size = 13
	#endregion

	#region TooltipPanel
	var tooltip_panel := theme.create_theme_type("TooltipPanel", "PanelContainer")

	tooltip_panel.panel = _create_style_box_flat({
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
