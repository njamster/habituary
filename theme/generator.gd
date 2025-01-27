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
const FROST_2 := Color("#88C0D0")
const FROST_3 := Color("#81A1C1")
const FROST_4 := Color("#5E81AC")

# secondary colors
const AURORA_1 := Color("#BF616A")
const AURORA_2 := Color("#D08770")
const AURORA_3 := Color("#EBCB8B")
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

	theme.background_color = neutral_1

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

	left_sidebar_button.font_hover_color = neutral_1

	left_sidebar_button.set_main_style({
		"corner_radius" = { "top_right": 4, "bottom_right": 4 },
		"content_margin" = 4,
	})
	left_sidebar_button.disabled = {
		"bg_color" = Color(neutral_3, 0.3),
	}
	left_sidebar_button.focus = {
		"draw_center" = false,
		"border_width" = { "top": 2, "right": 2, "bottom": 2 },
		"expand_margin" = { "top": 2, "right": 2, "bottom": 2 },
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

	line_edit.caret_width = 2

	line_edit.font_color = neutral_7
	line_edit.font_placeholder_color = Color(neutral_7, 0.6)
	#endregion

	#region LineEdit_Minimal
	var line_edit_minimal := theme.create_theme_type("LineEdit_Minimal", "LineEdit")

	line_edit_minimal.minimum_character_width = 0

	line_edit_minimal.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region LineEdit_SearchMatch
	var line_edit_search_match := theme.create_theme_type("LineEdit_SearchMatch", "LineEdit")

	line_edit_search_match.font_color = primary_2

	line_edit_search_match.minimum_character_width = 0

	line_edit_search_match.set_main_style({
		# StyleBoxEmpty
	})
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

	right_sidebar_button.font = load("res://theme/fonts/OpenSans-ExtraBold.ttf")

	right_sidebar_button.font_size = 12

	right_sidebar_button.set_main_style({
		"corner_radius" = { "top_left": 4, "bottom_left": 4 },
		"content_margin" = 4,
	})
	right_sidebar_button.disabled = {
		"bg_color" = Color(neutral_3, 0.3),
	}
	right_sidebar_button.focus = {
		"draw_center" = false,
		"border_width" = { "left": 2, "top": 2, "bottom": 2 },
		"expand_margin" = { "left": 2, "top": 2, "bottom": 2 },
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
		"border_width" = { "right": 4 },
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

	today_count_label.font_color = neutral_1
	today_count_label.font_size = 9
	#endregion

	#region KeyBindingLabel
	var key_binding_label := theme.create_theme_type("KeyBindingLabel", "Label")

	key_binding_label.font_size = 12

	key_binding_label.normal = {
		"bg_color" = primary_3,
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

	scroll_button_text.font_color = primary_1

	scroll_button_text.font_size = 12
	#endregion

	#region ScrollButtonText_SearchMatch
	var scroll_button_text_search_match := theme.create_theme_type("ScrollButtonText_SearchMatch", "Label")

	scroll_button_text_search_match.font_color = primary_2

	scroll_button_text_search_match.font_size = 12
	#endregion

	#region LargeSeparation
	var large_separation := theme.create_theme_type("LargeSeparation", "BoxContainer")

	large_separation.separation = 32
	#endregion

	#region MediumSeparation
	var medium_separation := theme.create_theme_type("MediumSeparation", "BoxContainer")

	medium_separation.separation = 16
	#endregion

	#region TodoList_ItemSeparation
	var todo_list_item_separation := theme.create_theme_type("TodoList_ItemSeparation", "BoxContainer")

	todo_list_item_separation.separation = 13
	#endregion

	#region SmallSeparation
	var small_separation := theme.create_theme_type("SmallSeparation", "BoxContainer")

	small_separation.separation = 8
	#endregion

	#region NoSeparation
	var no_separation := theme.create_theme_type("NoSeparation", "BoxContainer")

	no_separation.separation = 0
	#endregion

	#region FlatButton
	var flat_button := theme.create_theme_type("FlatButton", "Button")

	flat_button.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region ToDoItem_ExtraInfo
	var to_do_item_extra_info := theme.create_theme_type("ToDoItem_ExtraInfo", "Label")

	to_do_item_extra_info.font_size = 10

	to_do_item_extra_info.normal = {
		"content_margin" = { "left": 3, "right": 3 }
	}
	#endregion

	#region ToDoItem_EditingOptions
	var to_do_item_editing_options := theme.create_theme_type("ToDoItem_EditingOptions", "PanelContainer")

	to_do_item_editing_options.set_main_style({
		"bg_color" = primary_1,
		"corner_radius" = 6,
		"content_margin" = { "left": 6, "right": 6 }
	})
	#endregion

	#region SearchBar_ShortcutHint
	var search_bar_shortcut_hint := theme.create_theme_type("SearchBar_ShortcutHint", "Button")

	search_bar_shortcut_hint.set_default_color(primary_1)

	search_bar_shortcut_hint.font_size = 11

	search_bar_shortcut_hint.set_main_style({
		"bg_color" = neutral_4,
		"corner_radius" = 3,
		"content_margin" = { "left": 4, "right": 4 }
	})
	#endregion

	#region Label_Error
	var label_error := theme.create_theme_type("Label_Error", "Label")

	label_error.font_color = secondary_1
	#endregion

	#region EntryPoint_OuterMargin
	var entry_point_outer_margin := theme.create_theme_type("EntryPoint_OuterMargin", "MarginContainer")

	entry_point_outer_margin.margin_left = 12
	entry_point_outer_margin.margin_top = 10
	entry_point_outer_margin.margin_right = 12
	entry_point_outer_margin.margin_bottom = 14
	#endregion

	#region Label_Italic
	var label_italic := theme.create_theme_type("Label_Italic", "Label")

	label_italic.font = load("res://theme/fonts/OpenSans-MediumItalic.ttf")
	#endregion

	#region LineEdit_VersionNumber
	var line_edit_version_number := theme.create_theme_type("LineEdit_VersionNumber", "LineEdit")

	line_edit_version_number.font_uneditable_color = primary_3
	#endregion

	#region Calendar_ExtraPadding
	var calendar_extra_padding := theme.create_theme_type("Calendar_ExtraPadding", "MarginContainer")

	calendar_extra_padding.margin_left = 40
	calendar_extra_padding.margin_top = 87
	calendar_extra_padding.margin_right = 40
	#endregion

	#region ToDoList_VerticalPadding
	var to_do_list_vertical_padding := theme.create_theme_type("ToDoList_VerticalPadding", "MarginContainer")

	to_do_list_vertical_padding.margin_top = 6
	to_do_list_vertical_padding.margin_bottom = 7
	#endregion

	#region ToDoItem_TogglePadding
	var to_do_item_toggle_padding := theme.create_theme_type("ToDoItem_TogglePadding", "MarginContainer")

	to_do_item_toggle_padding.margin_left = 6
	to_do_item_toggle_padding.margin_right = 6
	#endregion

	#region ToDoItem_ContentPadding
	var to_do_item_content_padding := theme.create_theme_type("ToDoItem_ContentPadding", "MarginContainer")

	to_do_item_content_padding.margin_right = 6
	#endregion

	#region ToDoItem_BookmarkButton
	var to_do_item_bookmark_button := theme.create_theme_type("ToDoItem_BookmarkButton", "Button")

	to_do_item_bookmark_button.font_size = 12

	to_do_item_bookmark_button.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region ToDoItem_DeleteButton
	var to_do_item_delete_button := theme.create_theme_type("ToDoItem_DeleteButton", "Button")

	to_do_item_delete_button.font_hover_color = secondary_1
	to_do_item_delete_button.icon_hover_color = secondary_1
	to_do_item_delete_button.font_pressed_color = secondary_2
	to_do_item_delete_button.icon_pressed_color = secondary_2

	to_do_item_delete_button.font_size = 12

	to_do_item_delete_button.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region ToDoItem_EditingOption
	var to_do_item_editing_option := theme.create_theme_type("ToDoItem_EditingOption", "Button")

	to_do_item_editing_option.icon_pressed_color = secondary_3

	to_do_item_editing_option.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region PopupMenu
	var popup_menu := theme.create_theme_type("PopupMenu")

	popup_menu.font_color = neutral_5
	popup_menu.font_hover_color = primary_1

	popup_menu.set_main_style({
		"bg_color": neutral_3,
	})
	#endregion

	#region DayPanel
	var day_panel := theme.create_theme_type("DayPanel", "PanelContainer")

	day_panel.set_main_style({
		"content_margin" = 0,
	})
	#endregion

	#region DayPanel_CurrentDay
	var day_panel_current_day := theme.create_theme_type("DayPanel_CurrentDay", "PanelContainer")

	day_panel_current_day.set_main_style({
		"bg_color" = neutral_2,
		"corner_radius" = { "top_left": 16, "top_right": 16 },
		"expand_margin" = { "left": 8, "top": 8, "right": 8, "bottom": 30 },
		"content_margin" = 0,
	})
	#endregion

	#region DayPanel_Header_Selected
	var day_panel_header_selected := theme.create_theme_type("DayPanel_Header_Selected", "PanelContainer")

	day_panel_header_selected.set_main_style({
		"bg_color" = neutral_3,
		"draw_center" = true,
		"corner_radius" = 8,
		"content_margin" = { "left": 4, "top": 4, "right": 4, "bottom": 2 },
	})
	#endregion

	#region DayPanel_Header
	var day_panel_header := theme.create_theme_type("DayPanel_Header", "PanelContainer")

	day_panel_header.set_main_style({
		"draw_center" = false,
		"content_margin" = { "left": 4, "top": 4, "right": 4, "bottom": 2 },
	})
	#endregion

	#region ToDoItem
	var to_do_item := theme.create_theme_type("ToDoItem", "Button")

	to_do_item.set_default_color(neutral_6)

	to_do_item.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region ToDoItem_Focused
	var to_do_item_focused := theme.create_theme_type("ToDoItem_Focused", "Button")

	to_do_item_focused.set_default_color(primary_4)

	to_do_item_focused.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region ToDoItem_Done
	var to_do_item_done := theme.create_theme_type("ToDoItem_Done", "Button")

	to_do_item_done.set_default_color(secondary_4)

	to_do_item_done.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region ToDoItem_Failed
	var to_do_item_failed := theme.create_theme_type("ToDoItem_Failed", "Button")

	to_do_item_failed.set_default_color(secondary_1)

	to_do_item_failed.set_main_style({
		# StyleBoxEmpty
	})
	#endregion

	#region ToDoItem_NoHeading
	var to_do_item_no_heading := theme.create_theme_type("ToDoItem_NoHeading", "PanelContainer")

	to_do_item_no_heading.set_main_style({
		"draw_center" = false,
	})
	#endregion

	#region ToDoItem_Heading
	var to_do_item_heading := theme.create_theme_type("ToDoItem_Heading", "PanelContainer")

	to_do_item_heading.set_main_style({
		"bg_color" = neutral_3,
		"corner_radius" = 6,
		"resource_local_to_scene" = true
	})
	#endregion

	# ----------------------------------------

	# Keep UIDs from the previous version of the theme, if there are any. Without this, re-running
	# this script would assign new UIDs to *all* StyleBoxes, Icons and Fonts in the theme, even if
	# their properties didn't change at all (which is really annoying for version control).
	if ResourceLoader.exists(file_path):
		var previous_version := ResourceLoader.load(file_path)

		for theme_type in theme.get_type_list():
			for data_type in [
				Theme.DATA_TYPE_FONT,
				Theme.DATA_TYPE_ICON,
				Theme.DATA_TYPE_STYLEBOX,
			]:
				for item_name in theme.get_theme_item_list(data_type, theme_type):
					var new = theme.get_theme_item(data_type, item_name, theme_type)
					var old = previous_version.get_theme_item(data_type, item_name, theme_type)
					new.resource_scene_unique_id = old.resource_scene_unique_id

	# NOTE: Inspecting updated themes in Godot won't show the most recent version, see:
	#   https://github.com/godotengine/godot/issues/30302
	# If that is required, reload the project via "Project" -> "Reload Current Project".
	ResourceSaver.save(theme, file_path)
