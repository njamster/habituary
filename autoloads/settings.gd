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

enum FadeNonTodayDates {
	NONE,
	PAST,
	FUTURE,
	PAST_AND_FUTURE
}

enum SidePanelState {
	HIDDEN,
	HELP,
	BOOKMARKS,
	CAPTURE,
	SETTINGS
}

var to_do_text_colors := [
	Color("#BF616A"),
	Color("#D08770"),
	Color("#EBCB8B"),
	Color("#A3BE8C"),
	Color("#B48EAD"),
]

var DEFAULT_STORE_PATH : String:
	get():
		if OS.has_feature("editor"):
			return ProjectSettings.globalize_path("user://")
		elif OS.has_feature("windows"):
			return OS.get_environment("USERPROFILE") + "/habituary/"
		else:
			return OS.get_environment("HOME") + "/habituary/"

var store_path := DEFAULT_STORE_PATH

var settings_path : String

var date_format_save := "YYYY-MM-DD"

var today_position := TodayPosition.CENTERED:
	set(value):
		today_position = value
		EventBus.current_day_changed.emit(current_day)
		if is_node_ready():
			if OS.is_debug_build():
				print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
			debounce_timer.start()

var previous_view_mode

var view_mode := 3:
	set(value):
		if previous_view_mode != view_mode:
			previous_view_mode = null
		view_mode = value
		EventBus.view_mode_changed.emit(view_mode)
		if is_node_ready():
			if OS.is_debug_build():
				print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
			debounce_timer.start()

var previous_day

var current_day := DayTimer.today:
	set(value):
		if current_day.day_difference_to(value) != 0:
			if previous_day != current_day:
				previous_day = null
			current_day = value
			EventBus.current_day_changed.emit(current_day)

var start_week_on_monday := true:
	set(value):
		start_week_on_monday = value
		if is_node_ready():
			if OS.is_debug_build():
				print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
			debounce_timer.start()

var day_start_hour_offset := 0:
	set(value):
		if value != day_start_hour_offset:
			day_start_hour_offset = value
			EventBus.day_start_changed.emit()
			if is_node_ready():
				if OS.is_debug_build():
					print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
				debounce_timer.start()

var day_start_minute_offset := 0:
	set(value):
		if value != day_start_minute_offset:
			day_start_minute_offset = value
			EventBus.day_start_changed.emit()
			if is_node_ready():
				if OS.is_debug_build():
					print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
				debounce_timer.start()

var dark_mode := true:
	set(value):
		dark_mode = value

		if dark_mode:
			RenderingServer.set_default_clear_color("#2E3440")
			get_tree().current_scene.theme = preload("res://theme/dark_theme.tres")
		else:
			RenderingServer.set_default_clear_color("#F5F5F5")
			get_tree().current_scene.theme = preload("res://theme/light_theme.tres")

		EventBus.dark_mode_changed.emit(dark_mode)

		if is_node_ready():
			if OS.is_debug_build():
				print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
			debounce_timer.start()

var search_query := "":
	set(value):
		search_query = value
		EventBus.search_query_changed.emit()

var side_panel := SidePanelState.HIDDEN:
	set(value):
		side_panel = value
		EventBus.side_panel_changed.emit()
		if is_node_ready():
			if OS.is_debug_build():
				print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
			debounce_timer.start()

var show_bookmarks_from_the_past := true:
	set(value):
		show_bookmarks_from_the_past = value
		EventBus.show_bookmarks_from_the_past_changed.emit()
		if is_node_ready():
			if OS.is_debug_build():
				print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
			debounce_timer.start()

var fade_ticked_off_todos := true:
	set(value):
		fade_ticked_off_todos = value
		EventBus.fade_ticked_off_todos_changed.emit()
		if is_node_ready():
			if OS.is_debug_build():
				print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
			debounce_timer.start()

var fade_non_today_dates := FadeNonTodayDates.PAST:
	set(value):
		fade_non_today_dates = value
		EventBus.fade_non_today_dates_changed.emit()
		if is_node_ready():
			if OS.is_debug_build():
				print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
			debounce_timer.start()

var bookmarks_due_today := 0:
	set(value):
		bookmarks_due_today = value
		EventBus.bookmarks_due_today_changed.emit()

@onready var debounce_timer := Timer.new()


func _enter_tree() -> void:
	get_window().wrap_controls = true # Sadly, there is no ProjectSetting to enable this by default

	if OS.has_feature("editor"):
		settings_path = ProjectSettings.globalize_path("user://debug_settings.cfg")
	else:
		settings_path = ProjectSettings.globalize_path("user://settings.cfg")

	load_from_disk()


func _ready() -> void:
	debounce_timer.wait_time = 6.0  # seconds
	debounce_timer.one_shot = true
	add_child(debounce_timer)

	debounce_timer.timeout.connect(func():
		if OS.is_debug_build():
			print("[DEBUG] DebounceTimer Timed Out: Saving Settings...")
		save_to_disk()
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_to_disk()


func save_to_disk() -> void:
	var config = ConfigFile.new()
	config.load(settings_path) # keep existing settings (if there are any)
	config.set_value("AppState", "dark_mode", dark_mode)
	config.set_value("AppState", "today_position", today_position)
	config.set_value("AppState", "view_mode", view_mode)
	config.set_value("AppState", "start_week_on_monday", start_week_on_monday)
	config.set_value("AppState", "day_start_hour_offset", day_start_hour_offset)
	config.set_value("AppState", "day_start_minute_offset", day_start_minute_offset)
	config.set_value("AppState", "side_panel", side_panel)
	config.set_value("AppState", "show_bookmarks_from_the_past", show_bookmarks_from_the_past)
	config.set_value("AppState", "fade_ticked_off_todos", fade_ticked_off_todos)
	config.set_value("AppState", "fade_non_today_dates", fade_non_today_dates)
	config.save(settings_path)

	if OS.is_debug_build():
		print("[DEBUG] Settings Saved to Disk!")


func load_from_disk() -> void:
	var config := ConfigFile.new()
	var error := config.load(settings_path)
	if not error:
		dark_mode = config.get_value("AppState", "dark_mode", dark_mode)
		today_position = config.get_value("AppState", "today_position", today_position)
		view_mode = config.get_value("AppState", "view_mode", view_mode)
		start_week_on_monday = config.get_value("AppState", "start_week_on_monday", start_week_on_monday)
		day_start_hour_offset = config.get_value("AppState", "day_start_hour_offset", day_start_hour_offset)
		day_start_minute_offset = config.get_value("AppState", "day_start_minute_offset", day_start_minute_offset)
		side_panel = config.get_value("AppState", "side_panel", side_panel)
		show_bookmarks_from_the_past = config.get_value("AppState", "show_bookmarks_from_the_past", show_bookmarks_from_the_past)
		fade_ticked_off_todos = config.get_value("AppState", "fade_ticked_off_todos", fade_ticked_off_todos)
		fade_non_today_dates = config.get_value("AppState", "fade_non_today_dates", fade_non_today_dates)
