extends Node

#region COLOR THEME
# dark colors
const NORD_00 = Color("#2E3440")
const NORD_01 = Color("#3B4252")
const NORD_02 = Color("#434C5E")
const NORD_03 = Color("#4C566A")

# light colors
const NORD_04 = Color("#D8DEE9")
const NORD_05 = Color("#E5E9F0")
const NORD_06 = Color("#ECEFF4")

# frost colors
const NORD_07 = Color("#8FBCBB")
const NORD_08 = Color("#88C0D0")
const NORD_09 = Color("#81A1C1")
const NORD_10 = Color("#5E81AC")
#endregion

enum TodayPosition {
	LEFTMOST,
	SECOND_PLACE,
	CENTERED
}

const SETTINGS_PATH := "user://settings.cfg"

var date_format_save := "YYYY-MM-DD"

var store_path : String

var today_position := TodayPosition.CENTERED:
	set(value):
		today_position = value
		EventBus.current_day_changed.emit(current_day)

var view_mode := 3:
	set(value):
		view_mode = value
		EventBus.view_mode_changed.emit(view_mode)

var current_day := DayTimer.today:
	set(value):
		if current_day.day_difference_to(value) != 0:
			current_day = value
			EventBus.current_day_changed.emit(current_day)

var start_week_on_monday := true

var day_start_hour_offset := 0:
	set(value):
		if value != day_start_hour_offset:
			var old_value := day_start_hour_offset
			day_start_hour_offset = value
			var shift := value - old_value
			EventBus.day_start_hour_offset_changed.emit(shift)

var dark_mode := true:
	set(value):
		dark_mode = value
		var theme := ThemeDB.get_project_theme()
		if dark_mode:
			RenderingServer.set_default_clear_color("#2E3440")
			theme.set_color("font_color", "Label", NORD_06)

			theme.set_color("font_color", "SubtleLabel", NORD_04)

			theme.set_color("font_color", "LineEdit", NORD_06)
			theme.set_color("font_placeholder_color", "LineEdit", Color(NORD_06, 0.6))

			for type in ["LeftSidebarButton", "RightSidebarButton"]:
				theme.set_color("font_color", type, NORD_06)
				theme.set_color("icon_normal_color", type, NORD_06)
				var button_stylebox := theme.get_stylebox("normal", type)
				button_stylebox.bg_color = NORD_02
				theme.set_stylebox("normal", type, button_stylebox)

			var panel_stylebox := theme.get_stylebox("panel", "PanelContainer")
			panel_stylebox.bg_color = NORD_00
			theme.set_stylebox("panel", "PanelContainer", panel_stylebox)

			var tooltip_stylebox := theme.get_stylebox("panel", "TooltipPanel")
			tooltip_stylebox.bg_color = NORD_03
			theme.set_stylebox("panel", "TooltipPanel", tooltip_stylebox)

			var panel_container_popup := theme.get_stylebox("panel", "PanelContainer_Popup")
			panel_container_popup.bg_color = NORD_01
			theme.set_stylebox("panel", "PanelContainer_Popup", panel_container_popup)

			var day_button_hover := theme.get_stylebox("hover", "CalendarWidget_DayButton")
			day_button_hover.bg_color = NORD_02
			theme.set_stylebox("hover", "CalendarWidget_DayButton", day_button_hover)

			var day_button_selected_hover := theme.get_stylebox("hover", "CalendarWidget_DayButton_Selected")
			day_button_selected_hover.bg_color = NORD_04
			theme.set_stylebox("hover", "CalendarWidget_DayButton_Selected", day_button_selected_hover)

			var day_button_today_hover := theme.get_stylebox("hover", "CalendarWidget_DayButton_Today")
			day_button_today_hover.bg_color = NORD_04
			theme.set_stylebox("hover", "CalendarWidget_DayButton_Today", day_button_today_hover)

			theme.set_color("font_color", "CalendarWidget_DayButton", NORD_06)
			theme.set_color("font_hover_color", "CalendarWidget_DayButton", NORD_06)

			theme.set_color("font_color", "CalendarWidget_DayButton_Selected", NORD_06)
			theme.set_color("font_hover_color", "CalendarWidget_DayButton_Selected", NORD_00)

			theme.set_color("font_color", "CalendarWidget_DayButton_Today", NORD_06)
			theme.set_color("font_hover_color", "CalendarWidget_DayButton_Today", NORD_00)

			theme.set_color("font_color", "CalendarWidget_Button", NORD_06)
			theme.set_color("icon_normal_color", "CalendarWidget_Button", NORD_06)
			theme.set_color("icon_disabled_color", "CalendarWidget_Button", Color(NORD_06, 0.3))
			var button_stylebox := theme.get_stylebox("normal", "CalendarWidget_Button")
			button_stylebox.bg_color = NORD_03
			theme.set_stylebox("normal", "CalendarWidget_Button", button_stylebox)
			var button_disabled_stylebox := theme.get_stylebox("disabled", "CalendarWidget_Button")
			button_disabled_stylebox.bg_color = Color(NORD_03, 0.3)
			theme.set_stylebox("normal", "CalendarWidget_Button", button_disabled_stylebox)
		else:
			RenderingServer.set_default_clear_color("#ECEFF4")
			theme.set_color("font_color", "Label", NORD_00)

			theme.set_color("font_color", "SubtleLabel", NORD_02)

			theme.set_color("font_color", "LineEdit", NORD_00)
			theme.set_color("font_placeholder_color", "LineEdit", Color(NORD_00, 0.6))

			for type in ["LeftSidebarButton", "RightSidebarButton"]:
				theme.set_color("font_color", type, NORD_00)
				theme.set_color("icon_normal_color", type, NORD_00)
				var button_stylebox := theme.get_stylebox("normal", type)
				button_stylebox.bg_color = NORD_04
				theme.set_stylebox("normal", type, button_stylebox)

			var panel_stylebox := theme.get_stylebox("panel", "PanelContainer")
			panel_stylebox.bg_color = NORD_06
			theme.set_stylebox("panel", "PanelContainer", panel_stylebox)

			var tooltip_stylebox := theme.get_stylebox("panel", "TooltipPanel")
			tooltip_stylebox.bg_color = NORD_04
			theme.set_stylebox("panel", "TooltipPanel", tooltip_stylebox)

			var panel_container_popup := theme.get_stylebox("panel", "PanelContainer_Popup")
			panel_container_popup.bg_color = NORD_05
			theme.set_stylebox("panel", "PanelContainer_Popup", panel_container_popup)

			var day_button_hover := theme.get_stylebox("hover", "CalendarWidget_DayButton")
			day_button_hover.bg_color = NORD_04
			theme.set_stylebox("hover", "CalendarWidget_DayButton", day_button_hover)

			var day_button_selected_hover := theme.get_stylebox("hover", "CalendarWidget_DayButton_Selected")
			day_button_selected_hover.bg_color = NORD_01
			theme.set_stylebox("hover", "CalendarWidget_DayButton_Selected", day_button_selected_hover)

			var day_button_today_hover := theme.get_stylebox("hover", "CalendarWidget_DayButton_Today")
			day_button_today_hover.bg_color = NORD_01
			theme.set_stylebox("hover", "CalendarWidget_DayButton_Today", day_button_today_hover)

			theme.set_color("font_color", "CalendarWidget_DayButton", NORD_00)
			theme.set_color("font_hover_color", "CalendarWidget_DayButton", NORD_00)

			theme.set_color("font_color", "CalendarWidget_DayButton_Selected", NORD_00)
			theme.set_color("font_hover_color", "CalendarWidget_DayButton_Selected", NORD_06)

			theme.set_color("font_color", "CalendarWidget_DayButton_Today", NORD_00)
			theme.set_color("font_hover_color", "CalendarWidget_DayButton_Today", NORD_06)

			theme.set_color("font_color", "CalendarWidget_Button", NORD_00)
			theme.set_color("icon_normal_color", "CalendarWidget_Button", NORD_00)
			theme.set_color("icon_disabled_color", "CalendarWidget_Button", Color(NORD_00, 0.3))
			var button_stylebox := theme.get_stylebox("normal", "CalendarWidget_Button")
			button_stylebox.bg_color = NORD_04
			theme.set_stylebox("normal", "CalendarWidget_Button", button_stylebox)
			var button_disabled_stylebox := theme.get_stylebox("disabled", "CalendarWidget_Button")
			button_disabled_stylebox.bg_color = Color(NORD_04, 0.3)
			theme.set_stylebox("normal", "CalendarWidget_Button", button_disabled_stylebox)
		EventBus.dark_mode_changed.emit(dark_mode)


func _enter_tree() -> void:
	if OS.is_debug_build():
		store_path = ProjectSettings.globalize_path("user://")
	else:
		if OS.has_feature("windows"):
			store_path = OS.get_environment("USERPROFILE") + "/habituary/"
		else:
			store_path = OS.get_environment("HOME") + "/habituary/"

	if OS.is_debug_build():
		return

	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if not error:
		dark_mode = config.get_value("AppState", "dark_mode", dark_mode)
		today_position = config.get_value("AppState", "today_position", today_position)
		view_mode = config.get_value("AppState", "view_mode", view_mode)
		start_week_on_monday = config.get_value("AppState", "start_week_on_monday", start_week_on_monday)
		day_start_hour_offset = config.get_value("AppState", "day_start_hour_offset", day_start_hour_offset)


func _notification(what: int) -> void:
	if OS.is_debug_build():
		return

	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var config = ConfigFile.new()
		config.load(SETTINGS_PATH) # keep existing settings (if there are any)
		config.set_value("AppState", "dark_mode", dark_mode)
		config.set_value("AppState", "today_position", today_position)
		config.set_value("AppState", "view_mode", view_mode)
		config.set_value("AppState", "start_week_on_monday", start_week_on_monday)
		config.set_value("AppState", "day_start_hour_offset", day_start_hour_offset)
		config.save(SETTINGS_PATH)
