@tool
extends EditorScript

## This function will get called when this EditorScript is executed, clicking "File" > "Run" in the
## Script Editor, or pressing its associated keyboard shortcut (Ctrl + Shift + X, by default).
func _run():
	_create_theme("dark_theme.tres") # TODO: work in progress!
	#_create_theme("light_theme.tres")


func _create_theme(file_name : String) -> void:
	var base_dir : String = get_script().get_path().get_base_dir()
	var file_path := base_dir.path_join(file_name)

	var theme := Theme.new()

	theme.add_type("AcceptDialog")
	theme.set_stylebox("panel", "AcceptDialog", StyleBoxFlat.new())

	theme.add_type("Bookmark_Today")
	theme.set_type_variation("Bookmark_Today", "PanelContainer")
	theme.set_stylebox("panel", "Bookmark_Today", StyleBoxFlat.new())

	theme.add_type("CalendarWidget_Button")
	theme.set_type_variation("CalendarWidget_Button", "Button")
	theme.set_color("icon_normal_color", "CalendarWidget_Button", Color("#ECEFF4"))
	theme.set_stylebox("disabled", "CalendarWidget_Button", StyleBoxFlat.new())
	theme.set_stylebox("hover", "CalendarWidget_Button", StyleBoxFlat.new())
	theme.set_stylebox("normal", "CalendarWidget_Button", StyleBoxFlat.new())
	theme.set_stylebox("pressed", "CalendarWidget_Button", StyleBoxFlat.new())

	theme.add_type("CalendarWidget_DayButton")
	theme.set_type_variation("CalendarWidget_DayButton", "Button")
	theme.set_font_size("font_size", "CalendarWidget_DayButton", 14)
	theme.set_stylebox("hover", "CalendarWidget_DayButton", StyleBoxFlat.new())
	theme.set_stylebox("normal", "CalendarWidget_DayButton", StyleBoxFlat.new())
	theme.set_stylebox("pressed", "CalendarWidget_DayButton", StyleBoxFlat.new())

	theme.add_type("CalendarWidget_DayButton_Selected")
	theme.set_type_variation("CalendarWidget_DayButton_Selected", "Button")
	theme.set_color("font_hover_color", "CalendarWidget_DayButton_Selected", Color("#2E3440"))
	theme.set_font_size("font_size", "CalendarWidget_DayButton_Selected", 14)
	theme.set_stylebox("hover", "CalendarWidget_DayButton_Selected", StyleBoxFlat.new())
	theme.set_stylebox("normal", "CalendarWidget_DayButton_Selected", StyleBoxFlat.new())
	theme.set_stylebox("pressed", "CalendarWidget_DayButton_Selected", StyleBoxFlat.new())

	theme.add_type("CalendarWidget_DayButton_Today")
	theme.set_type_variation("CalendarWidget_DayButton_Today", "Button")
	theme.set_color("font_hover_color", "CalendarWidget_DayButton_Today", Color("#2E3440"))
	theme.set_font_size("font_size", "CalendarWidget_DayButton_Today", 14)
	theme.set_stylebox("hover", "CalendarWidget_DayButton_Today", StyleBoxFlat.new())
	theme.set_stylebox("normal", "CalendarWidget_DayButton_Today", StyleBoxFlat.new())
	theme.set_stylebox("pressed", "CalendarWidget_DayButton_Today", StyleBoxFlat.new())

	theme.add_type("CalendarWidget_DayButton_WeekendDay")
	theme.set_type_variation("CalendarWidget_DayButton_WeekendDay", "Button")
	theme.set_color("font_color", "CalendarWidget_DayButton_WeekendDay", Color("#5E81AC"))
	theme.set_font_size("font_size", "CalendarWidget_DayButton_WeekendDay", 14)
	theme.set_stylebox("hover", "CalendarWidget_DayButton_WeekendDay", StyleBoxFlat.new())
	theme.set_stylebox("normal", "CalendarWidget_DayButton_WeekendDay", StyleBoxFlat.new())
	theme.set_stylebox("pressed", "CalendarWidget_DayButton_WeekendDay", StyleBoxFlat.new())

	theme.add_type("Label")
	theme.set_color("font_color", "Label", Color("#E5E9F0"))

	theme.add_type("Label_WeekendDay")
	theme.set_type_variation("Label_WeekendDay", "Label")
	theme.set_color("font_color", "Label_WeekendDay", Color("#5E81AC"))

	theme.add_type("LeftSidebarButton")
	theme.set_type_variation("LeftSidebarButton", "Button")
	theme.set_color("font_color", "LeftSidebarButton", Color("#ECEFF4"))
	theme.set_color("icon_normal_color", "LeftSidebarButton", Color("#ECEFF4"))
	theme.set_font_size("font_size", "LeftSidebarButton", 14)
	theme.set_stylebox("disabled", "LeftSidebarButton", StyleBoxFlat.new())
	theme.set_stylebox("focus", "LeftSidebarButton", StyleBoxFlat.new())
	theme.set_stylebox("hover", "LeftSidebarButton", StyleBoxFlat.new())
	theme.set_stylebox("normal", "LeftSidebarButton", StyleBoxFlat.new())
	theme.set_stylebox("pressed", "LeftSidebarButton", StyleBoxFlat.new())

	theme.add_type("LineEdit")
	theme.set_color("caret_color", "LineEdit", Color("#81A1C1"))
	theme.set_color("font_color", "LineEdit", Color("#ECEFF4"))
	theme.set_color("font_placeholder_color", "LineEdit", Color("#ECEFF499"))

	theme.add_type("PanelContainer")
	theme.set_stylebox("panel", "PanelContainer", StyleBoxFlat.new())

	theme.add_type("PanelContainer_Popup")
	theme.set_type_variation("PanelContainer_Popup", "PanelContainer")
	theme.set_stylebox("panel", "PanelContainer_Popup", StyleBoxFlat.new())

	theme.add_type("RightSidebarButton")
	theme.set_type_variation("RightSidebarButton", "Button")
	theme.set_color("font_color", "RightSidebarButton", Color("#ECEFF4"))
	theme.set_color("icon_normal_color", "RightSidebarButton", Color("#ECEFF4"))
	theme.set_font_size("font_size", "RightSidebarButton", 14)
	theme.set_stylebox("disabled", "RightSidebarButton", StyleBoxFlat.new())
	theme.set_stylebox("focus", "RightSidebarButton", StyleBoxFlat.new())
	theme.set_stylebox("hover", "RightSidebarButton", StyleBoxFlat.new())
	theme.set_stylebox("normal", "RightSidebarButton", StyleBoxFlat.new())
	theme.set_stylebox("pressed", "RightSidebarButton", StyleBoxFlat.new())

	theme.add_type("SearchBar")
	theme.set_type_variation("SearchBar", "PanelContainer")
	theme.set_stylebox("panel", "SearchBar", StyleBoxFlat.new())

	theme.add_type("SearchBar_Focused")
	theme.set_type_variation("SearchBar_Focused", "PanelContainer")
	theme.set_stylebox("panel", "SearchBar_Focused", StyleBoxFlat.new())

	theme.add_type("SearchBar_Hover")
	theme.set_type_variation("SearchBar_Hover", "PanelContainer")
	theme.set_stylebox("panel", "SearchBar_Hover", StyleBoxFlat.new())

	theme.add_type("SidePanel")
	theme.set_type_variation("SidePanel", "PanelContainer")
	theme.set_stylebox("panel", "SidePanel", StyleBoxFlat.new())

	theme.add_type("SubtleLabel")
	theme.set_type_variation("SubtleLabel", "Label")
	theme.set_color("font_color", "SubtleLabel", Color("#D8DEE9"))

	theme.add_type("TooltipLabel")
	theme.set_font_size("font_size", "TooltipLabel", 13)

	theme.add_type("TooltipPanel")
	theme.set_type_variation("TooltipPanel", "PanelContainer")
	theme.set_stylebox("panel", "TooltipPanel", StyleBoxFlat.new())

	# FIXME: Looks like Godot has issues updating on changed resources, see:
	#   https://github.com/godotengine/godot/issues/30302
	# Closing & reopening the project will reimport the resource properly, though!
	ResourceSaver.save(theme, file_path)
