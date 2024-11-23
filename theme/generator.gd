@tool
extends EditorScript

## This function will get called when this EditorScript is executed, clicking "File" > "Run" in the
## Script Editor, or pressing its associated keyboard shortcut (Ctrl + Shift + X, by default).
func _run():
	_create_theme("dark_theme") # TODO: work in progress!
	#_create_theme("light_theme")


func _create_theme(file_name : String) -> void:
	var base_dir : String = get_script().get_path().get_base_dir()
	var file_path := base_dir.path_join(file_name) + ".tres"

	var theme := Theme.new()

	theme.add_type("AcceptDialog")
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color("#2E3440")
	style_box.corner_detail = 5
	style_box.set_corner_radius_all(3)
	style_box.set_content_margin_all(8)
	theme.set_stylebox("panel", "AcceptDialog", style_box)

	theme.add_type("Bookmark_Today")
	theme.set_type_variation("Bookmark_Today", "PanelContainer")
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#2E3440")
	style_box.corner_detail = 5
	style_box.set_border_width_all(3)
	style_box.border_color = Color("A3BE8CBF")
	style_box.border_blend = true
	style_box.set_corner_radius_all(6)
	style_box.set_content_margin_all(12)
	theme.set_stylebox("panel", "Bookmark_Today", style_box)

	theme.add_type("CalendarWidget_Button")
	theme.set_type_variation("CalendarWidget_Button", "Button")
	theme.set_color("icon_normal_color", "CalendarWidget_Button", Color("#ECEFF4"))
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#4c566A4D")
	style_box.corner_detail = 5
	style_box.set_corner_radius_all(4)
	style_box.set_content_margin_all(4)
	theme.set_stylebox("disabled", "CalendarWidget_Button", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#81A1C1")
	style_box.corner_detail = 5
	style_box.set_corner_radius_all(4)
	style_box.set_content_margin_all(4)
	theme.set_stylebox("hover", "CalendarWidget_Button", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#4C566A")
	style_box.corner_detail = 5
	style_box.set_corner_radius_all(4)
	style_box.set_content_margin_all(4)
	theme.set_stylebox("normal", "CalendarWidget_Button", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#5E81AC")
	style_box.corner_detail = 5
	style_box.set_corner_radius_all(4)
	style_box.set_content_margin_all(4)
	theme.set_stylebox("pressed", "CalendarWidget_Button", style_box)

	theme.add_type("CalendarWidget_DayButton")
	theme.set_type_variation("CalendarWidget_DayButton", "Button")
	theme.set_font_size("font_size", "CalendarWidget_DayButton", 14)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#434C5E")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("hover", "CalendarWidget_DayButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.draw_center = false
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("normal", "CalendarWidget_DayButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#81A1C1")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("pressed", "CalendarWidget_DayButton", style_box)

	theme.add_type("CalendarWidget_DayButton_Selected")
	theme.set_type_variation("CalendarWidget_DayButton_Selected", "Button")
	theme.set_color("font_hover_color", "CalendarWidget_DayButton_Selected", Color("#2E3440"))
	theme.set_font_size("font_size", "CalendarWidget_DayButton_Selected", 14)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#D8DEE9")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("hover", "CalendarWidget_DayButton_Selected", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#81A1C1")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("normal", "CalendarWidget_DayButton_Selected", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#81A1c1")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("pressed", "CalendarWidget_DayButton_Selected", style_box)

	theme.add_type("CalendarWidget_DayButton_Today")
	theme.set_type_variation("CalendarWidget_DayButton_Today", "Button")
	theme.set_color("font_hover_color", "CalendarWidget_DayButton_Today", Color("#2E3440"))
	theme.set_font_size("font_size", "CalendarWidget_DayButton_Today", 14)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#D8DEE9")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("hover", "CalendarWidget_DayButton_Today", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#8FBCBB66")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("normal", "CalendarWidget_DayButton_Today", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#81A1C1")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("pressed", "CalendarWidget_DayButton_Today", style_box)

	theme.add_type("CalendarWidget_DayButton_WeekendDay")
	theme.set_type_variation("CalendarWidget_DayButton_WeekendDay", "Button")
	theme.set_color("font_color", "CalendarWidget_DayButton_WeekendDay", Color("#5E81AC"))
	theme.set_font_size("font_size", "CalendarWidget_DayButton_WeekendDay", 14)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#5E81AC")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("hover", "CalendarWidget_DayButton_WeekendDay", style_box)
	style_box = StyleBoxFlat.new()
	style_box.draw_center = false
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("normal", "CalendarWidget_DayButton_WeekendDay", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#81A1C1")
	style_box.set_corner_radius_all(45)
	theme.set_stylebox("pressed", "CalendarWidget_DayButton_WeekendDay", style_box)

	theme.add_type("Label")
	theme.set_color("font_color", "Label", Color("#E5E9F0"))

	theme.add_type("Label_WeekendDay")
	theme.set_type_variation("Label_WeekendDay", "Label")
	theme.set_color("font_color", "Label_WeekendDay", Color("#5E81AC"))

	theme.add_type("LeftSidebarButton")
	theme.set_type_variation("LeftSidebarButton", "Button")
	theme.set_color("font_color", "LeftSidebarButton", Color("#ECEFF4"))
	theme.set_color("icon_normal_color", "LeftSidebarButton", Color("#ECEFF4"))
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#434C5E4D")
	style_box.corner_detail = 5
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.set_content_margin_all(4)
	theme.set_stylebox("disabled", "LeftSidebarButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.draw_center = false
	style_box.corner_detail = 5
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.expand_margin_top = 2
	style_box.expand_margin_right = 2
	style_box.expand_margin_bottom = 2
	style_box.set_content_margin_all(4)
	theme.set_stylebox("focus", "LeftSidebarButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#81A1C1")
	style_box.corner_detail = 5
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.set_content_margin_all(4)
	theme.set_stylebox("hover", "LeftSidebarButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#434C5E")
	style_box.corner_detail = 5
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.set_content_margin_all(4)
	theme.set_stylebox("normal", "LeftSidebarButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#5E81AC")
	style_box.corner_detail = 5
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_right = 4
	style_box.set_content_margin_all(4)
	theme.set_stylebox("pressed", "LeftSidebarButton", style_box)

	theme.add_type("LineEdit")
	theme.set_color("caret_color", "LineEdit", Color("#81A1C1"))
	theme.set_color("font_color", "LineEdit", Color("#ECEFF4"))
	theme.set_color("font_placeholder_color", "LineEdit", Color("#ECEFF499"))

	theme.add_type("PanelContainer")
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#2E3440")
	style_box.corner_detail = 5
	style_box.set_corner_radius_all(6)
	style_box.set_content_margin_all(12)
	theme.set_stylebox("panel", "PanelContainer", style_box)

	theme.add_type("PanelContainer_Popup")
	theme.set_type_variation("PanelContainer_Popup", "PanelContainer")
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#3B4252")
	style_box.corner_detail = 5
	style_box.set_corner_radius_all(6)
	style_box.set_content_margin_all(12)
	theme.set_stylebox("panel", "PanelContainer_Popup", style_box)

	theme.add_type("RightSidebarButton")
	theme.set_type_variation("RightSidebarButton", "Button")
	theme.set_color("font_color", "RightSidebarButton", Color("#ECEFF4"))
	theme.set_color("icon_normal_color", "RightSidebarButton", Color("#ECEFF4"))
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#434C5E4D")
	style_box.corner_detail = 5
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_bottom_left = 4
	style_box.set_content_margin_all(4)
	theme.set_stylebox("disabled", "RightSidebarButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.draw_center = false
	style_box.corner_detail = 5
	style_box.border_width_top = 2
	style_box.border_width_left = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_bottom_left = 4
	style_box.expand_margin_top = 2
	style_box.expand_margin_left = 2
	style_box.expand_margin_bottom = 2
	style_box.set_content_margin_all(4)
	theme.set_stylebox("focus", "RightSidebarButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#81A1C1")
	style_box.corner_detail = 5
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_bottom_left = 4
	style_box.set_content_margin_all(4)
	theme.set_stylebox("hover", "RightSidebarButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#434C5E")
	style_box.corner_detail = 5
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_bottom_left = 4
	style_box.set_content_margin_all(4)
	theme.set_stylebox("normal", "RightSidebarButton", style_box)
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#5E81AC")
	style_box.corner_detail = 5
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_bottom_left = 4
	style_box.set_content_margin_all(4)
	theme.set_stylebox("pressed", "RightSidebarButton", style_box)

	theme.add_type("SearchBar")
	theme.set_type_variation("SearchBar", "PanelContainer")
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#3B4252")
	style_box.set_corner_radius_all(5)
	style_box.content_margin_left = 8
	style_box.content_margin_top = 4
	style_box.content_margin_right = 8
	style_box.content_margin_bottom = 4
	theme.set_stylebox("panel", "SearchBar", style_box)

	theme.add_type("SearchBar_Focused")
	theme.set_type_variation("SearchBar_Focused", "PanelContainer")
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#434C5E")
	style_box.set_border_width_all(2)
	style_box.border_color = Color("#5E81AC")
	style_box.set_corner_radius_all(5)
	style_box.content_margin_left = 8
	style_box.content_margin_top = 4
	style_box.content_margin_right = 8
	style_box.content_margin_bottom = 4
	theme.set_stylebox("panel", "SearchBar_Focused", style_box)

	theme.add_type("SearchBar_Hover")
	theme.set_type_variation("SearchBar_Hover", "PanelContainer")
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#434C5E")
	style_box.set_border_width_all(1)
	style_box.border_color = Color("#D8DEE9")
	style_box.set_corner_radius_all(5)
	style_box.content_margin_left = 8
	style_box.content_margin_top = 4
	style_box.content_margin_right = 8
	style_box.content_margin_bottom = 4
	theme.set_stylebox("panel", "SearchBar_Hover", style_box)

	theme.add_type("SidePanel")
	theme.set_type_variation("SidePanel", "PanelContainer")
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#434C5E")
	style_box.border_width_right = 4
	style_box.border_color = Color("#5E81AC")
	style_box.content_margin_left = 8
	style_box.content_margin_top = 8
	style_box.content_margin_right = 12
	style_box.content_margin_bottom = 8
	theme.set_stylebox("panel", "SidePanel", style_box)

	theme.add_type("SubtleLabel")
	theme.set_type_variation("SubtleLabel", "Label")
	theme.set_color("font_color", "SubtleLabel", Color("#D8DEE9"))

	theme.add_type("TooltipLabel")
	theme.set_font_size("font_size", "TooltipLabel", 13)

	theme.add_type("TooltipPanel")
	theme.set_type_variation("TooltipPanel", "PanelContainer")
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#4C566A")
	style_box.corner_detail = 5
	style_box.set_corner_radius_all(5)
	style_box.content_margin_left = 6
	style_box.content_margin_top = 2
	style_box.content_margin_right = 6
	style_box.content_margin_bottom = 2
	theme.set_stylebox("panel", "TooltipPanel", style_box)

	# FIXME: Looks like Godot has issues updating on changed resources, see:
	#   https://github.com/godotengine/godot/issues/30302
	# Closing & reopening the project will reimport the resource properly, though!
	ResourceSaver.save(theme, file_path)
