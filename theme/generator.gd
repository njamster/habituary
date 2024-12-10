@tool
extends EditorScript

#region Color Palette: https://www.nordtheme.com/
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
#endregion


## This function will get called when this EditorScript is executed, clicking "File" > "Run" in the
## Script Editor, or pressing its associated keyboard shortcut (Ctrl + Shift + X, by default).
func _run():
    _create_theme("dark_theme",
        #region Dark Color Palette
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
        #endregion
    )

    _create_theme("light_theme",
        #region Light Color Palette
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
        #endregion
    )


func _create_theme(file_name : String, neutral_1 : Color, neutral_2 : Color, neutral_3 : Color,
neutral_4 : Color, neutral_5 : Color, neutral_6 : Color, neutral_7 : Color, neutral_8 : Color,
primary_1 : Color, primary_2 : Color, primary_3 : Color, primary_4 : Color, secondary_1 : Color,
secondary_2 : Color, secondary_3 : Color, secondary_4 : Color, secondary_5 : Color) -> void:
    var base_dir : String = get_script().get_path().get_base_dir()
    var file_path := base_dir.path_join(file_name) + ".tres"

    var theme := ConciseTheme.new()

    theme.default_font_size = 14

    #region AcceptDialog
    var accept_dialog := theme.create_theme_type("AcceptDialog")

    accept_dialog.panel = {
        "bg_color" = neutral_1,
        "corner_radius" = 3,
        "content_margin" = 8,
    }
    #endregion

    #region Bookmark_Today
    var bookmark_today := theme.create_theme_type("Bookmark_Today", "PanelContainer")

    bookmark_today.panel = {
        "bg_color" = neutral_1,
        "border_width" = 3,
        "border_color" = Color(secondary_4, 0.75),
        "border_blend" = true,
        "corner_radius" = 6,
        "content_margin" = 12,
    }
    #endregion

    #region Button
    var button := theme.create_theme_type("Button")

    button.set_default_color(neutral_7)
    button.font_disabled_color = Color(neutral_7, 0.5)
    button.icon_disabled_color = Color(neutral_7, 0.5)

    button.set_main_style({
        "corner_radius" = 3,
        "content_margin" = 4,
    })
    button.focus = {
        "draw_center" = false,
        "border_width" = 2,
        "expand_margin" = 2,
    }
    button.hover = {
        "bg_color" = neutral_1,
    }
    button.normal = {
        "bg_color" = neutral_2,
    }
    button.pressed = {
        "bg_color" = primary_3,
    }

    #endregion

    #region CalendarWidget_Button
    var calendar_widget_button := theme.create_theme_type("CalendarWidget_Button", "Button")

    calendar_widget_button.set_main_style({
        "corner_radius" = 4,
        "content_margin" = 4,
    })
    calendar_widget_button.disabled = {
        "bg_color" = Color(neutral_4, 0.3),
    }
    calendar_widget_button.hover = {
        "bg_color" = primary_3,
    }
    calendar_widget_button.normal = {
        "bg_color" = neutral_4,
    }
    calendar_widget_button.pressed = {
        "bg_color" = neutral_4,
    }
    #endregion

    #region CalendarWidget_DayButton
    var calendar_widget_day_button := theme.create_theme_type("CalendarWidget_DayButton", "Button")

    calendar_widget_day_button.set_main_style({
        "corner_radius" = 45,
    })
    calendar_widget_day_button.hover = {
        "bg_color" = neutral_3,
    }
    calendar_widget_day_button.normal = {
        "draw_center" = false,
    }
    calendar_widget_day_button.pressed = {
        "bg_color" = primary_3,
    }
    #endregion

    #region CalendarWidget_DayButton_Selected
    var calendar_widget_day_button_selected := theme.create_theme_type("CalendarWidget_DayButton_Selected", "Button")

    calendar_widget_day_button_selected.font_hover_color = neutral_1

    calendar_widget_day_button_selected.set_main_style({
        "corner_radius" = 45,
    })
    calendar_widget_day_button_selected.hover = {
        "bg_color" = neutral_5,
    }
    calendar_widget_day_button_selected.normal = {
        "bg_color" = primary_3,
    }
    calendar_widget_day_button_selected.pressed = {
        "bg_color" = primary_3,
    }
    #endregion

    #region CalendarWidget_DayButton_Today
    var calendar_widget_day_button_today := theme.create_theme_type("CalendarWidget_DayButton_Today", "Button")

    calendar_widget_day_button_today.font_hover_color = neutral_1

    calendar_widget_day_button_today.set_main_style({
        "corner_radius" = 45,
    })
    calendar_widget_day_button_today.hover = {
        "bg_color" = neutral_5,
    }
    calendar_widget_day_button_today.normal = {
        "bg_color" = Color(primary_1, 0.4),
    }
    calendar_widget_day_button_today.pressed = {
        "bg_color" = primary_3,
    }
    #endregion

    #region CalendarWidget_DayButton_WeekendDay
    var calendar_widget_day_button_weekend_day := theme.create_theme_type("CalendarWidget_DayButton_WeekendDay", "Button")

    calendar_widget_day_button_weekend_day.font_color = primary_4

    calendar_widget_day_button_weekend_day.set_main_style({
        "corner_radius" = 45,
    })
    calendar_widget_day_button_weekend_day.hover = {
        "bg_color" = primary_4,
    }
    calendar_widget_day_button_weekend_day.normal = {
        "draw_center" = false,
    }
    calendar_widget_day_button_weekend_day.pressed = {
        "bg_color" = primary_3,
    }
    #endregion

    #region CheckButton
    var check_button := theme.create_theme_type("CheckButton")

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

    left_sidebar_button.set_main_style({
        "corner_radius" = { "top_left": 0, "top_right": 4, "bottom_right": 4, "bottom_left": 0 },
        "content_margin" = 4,
    })
    left_sidebar_button.disabled = {
        "bg_color" = Color(neutral_3, 0.3),
    }
    left_sidebar_button.focus = {
        "draw_center" = false,
        "border_width" = { "left": 0, "top": 2, "right": 2, "bottom": 2 },
        "expand_margin" = { "left": 0, "top": 2, "right": 2, "bottom": 2 },
    }
    left_sidebar_button.hover = {
        "bg_color" = primary_3,
    }
    left_sidebar_button.normal = {
        "bg_color" = neutral_3,
    }
    left_sidebar_button.pressed = {
        "bg_color" = primary_4,
    }
    #endregion

    #region LineEdit
    var line_edit := theme.create_theme_type("LineEdit")

    line_edit.caret_color = primary_3

    line_edit.font_color = neutral_7
    line_edit.font_placeholder_color = Color(neutral_7, 0.6)
    #endregion

    #region PanelContainer
    var panel_container := theme.create_theme_type("PanelContainer")

    panel_container.panel = {
        "bg_color" = neutral_1,
        "corner_radius" = 6,
        "content_margin" = 12,
    }
    #endregion

    #region PanelContainer_Popup
    var panel_container_popup := theme.create_theme_type("PanelContainer_Popup", "PanelContainer")

    panel_container_popup.panel = {
        "bg_color" = neutral_2,
        "corner_radius" = 6,
        "content_margin" = 12,
    }
    #endregion

    #region RichTextLabel
    var rich_text_label := theme.create_theme_type("RichTextLabel")

    rich_text_label.default_color = neutral_7
    #endregion

    #region RightSidebarButton
    var right_sidebar_button := theme.create_theme_type("RightSidebarButton", "Button")

    right_sidebar_button.font_size = 12

    right_sidebar_button.set_main_style({
        "corner_radius" = { "top_left": 4, "top_right": 0, "bottom_right": 0, "bottom_left": 4 },
        "content_margin" = 4,
    })
    right_sidebar_button.disabled = {
        "bg_color" = Color(neutral_3, 0.3),
    }
    right_sidebar_button.focus = {
        "draw_center" = false,
        "border_width" = { "left": 2, "top": 2, "right": 0, "bottom": 2 },
        "expand_margin" = { "left": 2, "top": 2, "right": 0, "bottom": 2 },
    }
    right_sidebar_button.hover = {
        "bg_color" = primary_3,
    }
    right_sidebar_button.normal = {
        "bg_color" = neutral_3,
    }
    right_sidebar_button.pressed = {
        "bg_color" = primary_4,
    }
    #endregion

    #region SearchBar
    var search_bar := theme.create_theme_type("SearchBar", "PanelContainer")

    search_bar.panel = {
        "bg_color" = neutral_2,
        "corner_radius" = 5,
        "content_margin" = { "left": 8, "top": 4, "right": 8, "bottom": 4 },
    }
    #endregion

    #region SearchBar_Focused
    var search_bar_focused := theme.create_theme_type("SearchBar_Focused", "SearchBar")

    search_bar_focused.panel = {
        "bg_color" = neutral_3,
        "border_width" = 2,
        "border_color" = primary_4,
        "corner_radius" = 5,
        "content_margin" = { "left": 8, "top": 4, "right": 8, "bottom": 4 },
    }
    #endregion

    #region SearchBar_Hover
    var search_bar_hover := theme.create_theme_type("SearchBar_Hover", "SearchBar")

    search_bar_hover.panel = {
        "bg_color" = neutral_3,
        "border_width" = 1,
        "border_color" = neutral_5,
        "corner_radius" = 5,
        "content_margin" = { "left": 8, "top": 4, "right": 8, "bottom": 4 },
    }
    #endregion

    #region SidePanel
    var side_panel := theme.create_theme_type("SidePanel", "PanelContainer")

    side_panel.panel = {
        "bg_color" = neutral_3,
        "border_width" = { "left": 0, "top": 0, "right": 4, "bottom": 0 },
        "border_color" = primary_4,
        "content_margin" = { "left": 8, "top": 8, "right": 12, "bottom": 8 },
    }
    #endregion

    #region SpinBox
    # var spin_box := theme.create_theme_type("SpinBox")
    # ...
    # NOTE: Cannot be themed properly yet! See: https://github.com/godotengine/godot/pull/89265
    # FIXME: Wait for Godot 4.4
    #endregion

    #region SubtleLabel
    var subtle_label := theme.create_theme_type("SubtleLabel", "Label")

    subtle_label.font_size = 12

    subtle_label.font_color = neutral_5
    #endregion

    #region TooltipLabel
    var tooltip_label := theme.create_theme_type("TooltipLabel")

    tooltip_label.font_size = 13
    #endregion

    #region TooltipPanel
    var tooltip_panel := theme.create_theme_type("TooltipPanel", "PanelContainer")

    tooltip_panel.panel = {
        "bg_color" = neutral_4,
        "corner_radius" = 5,
        "content_margin" = { "left": 6, "top": 2, "right": 6, "bottom": 2 },
    }
    #endregion

    #region TodayCountLabel
    var today_count_label := theme.create_theme_type("TodayCountLabel", "Label")

    today_count_label.font_size = 9
    #endregion

    #region KeyBindingLabel
    var key_binding_label := theme.create_theme_type("KeyBindingLabel", "Label")

    key_binding_label.font_size = 12

    key_binding_label.normal = {
        "bg_color" = FROST_3,
        "corner_radius" = 5,
        "content_margin" = 4
    }
    #endregion

    #region HeaderLarge
    var header_large := theme.create_theme_type("HeaderLarge", "Label")

    header_large.font_size = 24
    #endregion

    #region HeaderMedium
    var header_medium := theme.create_theme_type("HeaderMedium", "Label")

    header_medium.font_size = 20
    #endregion

    #region HeaderSmall
    var header_small := theme.create_theme_type("HeaderSmall", "Label")

    header_small.font_size = 16
    #endregion

    #region SmallText
    var small_text := theme.create_theme_type("SmallText", "Label")

    small_text.font_size = 12
    #endregion

    #region Explanation
    var explanation := theme.create_theme_type("Explanation", "RichTextLabel")

    explanation.normal_font_size = 12
    explanation.bold_font_size = 12
    #endregion

    #region ScrollButtonText
    var scroll_button_text := theme.create_theme_type("ScrollButtonText", "Label")

    scroll_button_text.font_color = FROST_1

    scroll_button_text.font_size = 12
    #endregion

    # NOTE: Inspecting updated themes in Godot won't show the most recent version, see:
    #   https://github.com/godotengine/godot/issues/30302
    # If that is required, reload the project via "Project" -> "Reload Current Project".
    ResourceSaver.save(theme, file_path)
