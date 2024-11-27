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

    var theme := Theme.new()

    theme.add_type("AcceptDialog")
    var style_box := StyleBoxFlat.new()
    style_box.bg_color = neutral_1
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(3)
    style_box.set_content_margin_all(8)
    theme.set_stylebox("panel", "AcceptDialog", style_box)

    theme.add_type("Bookmark_Today")
    theme.set_type_variation("Bookmark_Today", "PanelContainer")
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_1
    style_box.corner_detail = 5
    style_box.set_border_width_all(3)
    style_box.border_color = Color(secondary_4, 0.75)
    style_box.border_blend = true
    style_box.set_corner_radius_all(6)
    style_box.set_content_margin_all(12)
    theme.set_stylebox("panel", "Bookmark_Today", style_box)

    theme.add_type("Button")
    theme.set_color("font_color", "Button", neutral_6)
    theme.set_color("font_disabled_color", "Button", Color(neutral_6, 0.5))
    theme.set_color("font_focus_color", "Button", neutral_6)
    theme.set_color("font_hover_color", "Button", neutral_6)
    theme.set_color("font_hover_pressed_color", "Button", neutral_6)
    theme.set_color("font_pressed_color", "Button", neutral_6)
    theme.set_color("icon_disabled_color", "Button", Color(neutral_6, 0.5))
    theme.set_color("icon_focus_color", "Button", neutral_6)
    theme.set_color("icon_hover_color", "Button", neutral_6)
    theme.set_color("icon_hover_pressed_color", "Button", neutral_6)
    theme.set_color("icon_normal_color", "Button", neutral_6)
    theme.set_color("icon_pressed_color", "Button", neutral_6)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_6
    style_box.draw_center = false
    style_box.corner_detail = 5
    style_box.set_border_width_all(2)
    style_box.set_corner_radius_all(3)
    style_box.set_expand_margin_all(2)
    style_box.set_content_margin_all(4)
    theme.set_stylebox("focus", "Button", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_1
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(3)
    style_box.set_content_margin_all(4)
    theme.set_stylebox("hover", "Button", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_2
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(3)
    style_box.set_content_margin_all(4)
    theme.set_stylebox("normal", "Button", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_3
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(3)
    style_box.set_content_margin_all(4)
    theme.set_stylebox("pressed", "Button", style_box)

    theme.add_type("CalendarWidget_Button")
    theme.set_type_variation("CalendarWidget_Button", "Button")
    theme.set_color("font_color", "CalendarWidget_Button", neutral_7)
    theme.set_color("icon_normal_color", "CalendarWidget_Button", neutral_7)
    theme.set_color("icon_disabled_color", "CalendarWidget_Button", Color(neutral_7, 0.3))
    style_box = StyleBoxFlat.new()
    style_box.bg_color = Color(neutral_4, 0.3)
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(4)
    style_box.set_content_margin_all(4)
    theme.set_stylebox("disabled", "CalendarWidget_Button", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_3
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(4)
    style_box.set_content_margin_all(4)
    theme.set_stylebox("hover", "CalendarWidget_Button", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_4
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(4)
    style_box.set_content_margin_all(4)
    theme.set_stylebox("normal", "CalendarWidget_Button", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_4
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(4)
    style_box.set_content_margin_all(4)
    theme.set_stylebox("pressed", "CalendarWidget_Button", style_box)

    theme.add_type("CalendarWidget_DayButton")
    theme.set_type_variation("CalendarWidget_DayButton", "Button")
    theme.set_color("font_color", "CalendarWidget_DayButton", neutral_7)
    theme.set_color("font_hover_color", "CalendarWidget_DayButton", neutral_7)
    theme.set_font_size("font_size", "CalendarWidget_DayButton", 14)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_3
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("hover", "CalendarWidget_DayButton", style_box)
    style_box = StyleBoxFlat.new()
    style_box.draw_center = false
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("normal", "CalendarWidget_DayButton", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_3
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("pressed", "CalendarWidget_DayButton", style_box)

    theme.add_type("CalendarWidget_DayButton_Selected")
    theme.set_type_variation("CalendarWidget_DayButton_Selected", "Button")
    theme.set_color("font_color", "CalendarWidget_DayButton_Select", neutral_7)
    theme.set_color("font_hover_color", "CalendarWidget_DayButton_Selected", neutral_1)
    theme.set_font_size("font_size", "CalendarWidget_DayButton_Selected", 14)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_5
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("hover", "CalendarWidget_DayButton_Selected", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_3
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("normal", "CalendarWidget_DayButton_Selected", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_3
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("pressed", "CalendarWidget_DayButton_Selected", style_box)

    theme.add_type("CalendarWidget_DayButton_Today")
    theme.set_type_variation("CalendarWidget_DayButton_Today", "Button")
    theme.set_color("font_color", "CalendarWidget_DayButton_Today", neutral_7)
    theme.set_color("font_hover_color", "CalendarWidget_DayButton_Today", neutral_1)
    theme.set_font_size("font_size", "CalendarWidget_DayButton_Today", 14)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_5
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("hover", "CalendarWidget_DayButton_Today", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = Color(primary_1, 0.4)
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("normal", "CalendarWidget_DayButton_Today", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_3
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("pressed", "CalendarWidget_DayButton_Today", style_box)

    theme.add_type("CalendarWidget_DayButton_WeekendDay")
    theme.set_type_variation("CalendarWidget_DayButton_WeekendDay", "Button")
    theme.set_color("font_color", "CalendarWidget_DayButton_WeekendDay", primary_4)
    theme.set_font_size("font_size", "CalendarWidget_DayButton_WeekendDay", 14)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_4
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("hover", "CalendarWidget_DayButton_WeekendDay", style_box)
    style_box = StyleBoxFlat.new()
    style_box.draw_center = false
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("normal", "CalendarWidget_DayButton_WeekendDay", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_3
    style_box.set_corner_radius_all(45)
    theme.set_stylebox("pressed", "CalendarWidget_DayButton_WeekendDay", style_box)

    theme.add_type("CheckButton")
    theme.set_color("font_color", "CheckButton", neutral_7)
    theme.set_color("font_hover_color", "CheckButton", neutral_7)
    theme.set_color("font_pressed_color", "CheckButton", neutral_7)
    theme.set_color("font_hover_pressed_color", "CheckButton", neutral_7)
    theme.set_stylebox("disabled", "CheckButton", StyleBoxEmpty.new())
    theme.set_stylebox("focus", "CheckButton", StyleBoxEmpty.new())
    theme.set_stylebox("hover", "CheckButton", StyleBoxEmpty.new())
    theme.set_stylebox("hover_pressed", "CheckButton", StyleBoxEmpty.new())
    theme.set_stylebox("normal", "CheckButton", StyleBoxEmpty.new())
    theme.set_stylebox("pressed", "CheckButton", StyleBoxEmpty.new())

    theme.add_type("Label")
    theme.set_color("font_color", "Label", neutral_6)

    theme.add_type("Label_WeekendDay")
    theme.set_type_variation("Label_WeekendDay", "Label")
    theme.set_color("font_color", "Label_WeekendDay", primary_4)

    theme.add_type("LeftSidebarButton")
    theme.set_type_variation("LeftSidebarButton", "Button")
    theme.set_color("font_color", "LeftSidebarButton", neutral_7)
    theme.set_color("icon_normal_color", "LeftSidebarButton", neutral_7)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = Color(neutral_3, 0.3)
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
    style_box.bg_color = primary_3
    style_box.corner_detail = 5
    style_box.corner_radius_top_right = 4
    style_box.corner_radius_bottom_right = 4
    style_box.set_content_margin_all(4)
    theme.set_stylebox("hover", "LeftSidebarButton", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_3
    style_box.corner_detail = 5
    style_box.corner_radius_top_right = 4
    style_box.corner_radius_bottom_right = 4
    style_box.set_content_margin_all(4)
    theme.set_stylebox("normal", "LeftSidebarButton", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_4
    style_box.corner_detail = 5
    style_box.corner_radius_top_right = 4
    style_box.corner_radius_bottom_right = 4
    style_box.set_content_margin_all(4)
    theme.set_stylebox("pressed", "LeftSidebarButton", style_box)

    theme.add_type("LineEdit")
    theme.set_color("caret_color", "LineEdit", primary_3)
    theme.set_color("font_color", "LineEdit", neutral_7)
    theme.set_color("font_placeholder_color", "LineEdit", Color(neutral_7, 0.6))

    theme.add_type("PanelContainer")
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_1
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(6)
    style_box.set_content_margin_all(12)
    theme.set_stylebox("panel", "PanelContainer", style_box)

    theme.add_type("PanelContainer_Popup")
    theme.set_type_variation("PanelContainer_Popup", "PanelContainer")
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_2
    style_box.corner_detail = 5
    style_box.set_corner_radius_all(6)
    style_box.set_content_margin_all(12)
    theme.set_stylebox("panel", "PanelContainer_Popup", style_box)

    theme.add_type("RichTextLabel")
    theme.set_color("default_color", "RichTextLabel", neutral_7)

    theme.add_type("RightSidebarButton")
    theme.set_type_variation("RightSidebarButton", "Button")
    theme.set_color("font_color", "RightSidebarButton", neutral_7)
    theme.set_color("icon_normal_color", "RightSidebarButton", neutral_7)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = Color(neutral_3, 0.3)
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
    style_box.bg_color = primary_3
    style_box.corner_detail = 5
    style_box.corner_radius_top_left = 4
    style_box.corner_radius_bottom_left = 4
    style_box.set_content_margin_all(4)
    theme.set_stylebox("hover", "RightSidebarButton", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_3
    style_box.corner_detail = 5
    style_box.corner_radius_top_left = 4
    style_box.corner_radius_bottom_left = 4
    style_box.set_content_margin_all(4)
    theme.set_stylebox("normal", "RightSidebarButton", style_box)
    style_box = StyleBoxFlat.new()
    style_box.bg_color = primary_4
    style_box.corner_detail = 5
    style_box.corner_radius_top_left = 4
    style_box.corner_radius_bottom_left = 4
    style_box.set_content_margin_all(4)
    theme.set_stylebox("pressed", "RightSidebarButton", style_box)

    theme.add_type("SearchBar")
    theme.set_type_variation("SearchBar", "PanelContainer")
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_2
    style_box.set_corner_radius_all(5)
    style_box.content_margin_left = 8
    style_box.content_margin_top = 4
    style_box.content_margin_right = 8
    style_box.content_margin_bottom = 4
    theme.set_stylebox("panel", "SearchBar", style_box)

    theme.add_type("SearchBar_Focused")
    theme.set_type_variation("SearchBar_Focused", "PanelContainer")
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_3
    style_box.set_border_width_all(2)
    style_box.border_color = primary_4
    style_box.set_corner_radius_all(5)
    style_box.content_margin_left = 8
    style_box.content_margin_top = 4
    style_box.content_margin_right = 8
    style_box.content_margin_bottom = 4
    theme.set_stylebox("panel", "SearchBar_Focused", style_box)

    theme.add_type("SearchBar_Hover")
    theme.set_type_variation("SearchBar_Hover", "PanelContainer")
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_3
    style_box.set_border_width_all(1)
    style_box.border_color = neutral_5
    style_box.set_corner_radius_all(5)
    style_box.content_margin_left = 8
    style_box.content_margin_top = 4
    style_box.content_margin_right = 8
    style_box.content_margin_bottom = 4
    theme.set_stylebox("panel", "SearchBar_Hover", style_box)

    theme.add_type("SidePanel")
    theme.set_type_variation("SidePanel", "PanelContainer")
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_3
    style_box.border_width_right = 4
    style_box.border_color = primary_4
    style_box.content_margin_left = 8
    style_box.content_margin_top = 8
    style_box.content_margin_right = 12
    style_box.content_margin_bottom = 8
    theme.set_stylebox("panel", "SidePanel", style_box)

    # theme.add_type("SpinBox")
    # ...
    # NOTE: Cannot be themed properly yet! See: https://github.com/godotengine/godot/pull/89265
    # FIXME: Wait for Godot 4.4

    theme.add_type("SubtleLabel")
    theme.set_type_variation("SubtleLabel", "Label")
    theme.set_color("font_color", "SubtleLabel", neutral_5)

    theme.add_type("TooltipLabel")
    theme.set_font_size("font_size", "TooltipLabel", 13)

    theme.add_type("TooltipPanel")
    theme.set_type_variation("TooltipPanel", "PanelContainer")
    style_box = StyleBoxFlat.new()
    style_box.bg_color = neutral_4
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
