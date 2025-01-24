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

@export_group("Settings")
@export var store_path: String:
	set(value):
		if store_path == value:
			return

		store_path = value
		_start_debounce_timer()

var settings_path : String

var date_format_save := "YYYY-MM-DD"

@export_group("AppState")
@export var today_position := TodayPosition.CENTERED:
	set(value):
		if today_position == value:
			return

		today_position = value
		_start_debounce_timer()

		EventBus.current_day_changed.emit(current_day)

var previous_view_mode

@export var view_mode := 3:
	set(value):
		if view_mode == value:
			return

		if previous_view_mode != view_mode:
			previous_view_mode = null

		view_mode = value
		_start_debounce_timer()

		EventBus.view_mode_changed.emit(view_mode)

var previous_day

var current_day := DayTimer.today:
	set(value):
		if current_day.day_difference_to(value) == 0:
			return

		if previous_day != current_day:
			previous_day = null

		current_day = value

		EventBus.current_day_changed.emit(current_day)

@export var start_week_on_monday := true:
	set(value):
		if start_week_on_monday == value:
			return

		start_week_on_monday = value
		_start_debounce_timer()

@export var day_start_hour_offset := 0:
	set(value):
		if day_start_hour_offset == value:
			return

		day_start_hour_offset = value
		_start_debounce_timer()

		EventBus.day_start_changed.emit()

@export var day_start_minute_offset := 0:
	set(value):
		if day_start_minute_offset == value:
			return

		day_start_minute_offset = value
		_start_debounce_timer()

		EventBus.day_start_changed.emit()

@export var dark_mode := true:
	set(value):
		if dark_mode == value:
			return

		dark_mode = value
		_start_debounce_timer()

		if dark_mode:
			RenderingServer.set_default_clear_color("#2E3440")
			get_tree().get_root().theme = preload("res://theme/dark_theme.tres")
		else:
			RenderingServer.set_default_clear_color("#F5F5F5")
			get_tree().get_root().theme = preload("res://theme/light_theme.tres")

		EventBus.dark_mode_changed.emit(dark_mode)

var search_query := "":
	set(value):
		if search_query == value:
			return

		search_query = value

		EventBus.search_query_changed.emit()

@export var side_panel := SidePanelState.HIDDEN:
	set(value):
		if side_panel == value:
			return

		side_panel = value
		_start_debounce_timer()

		EventBus.side_panel_changed.emit()

@export var show_bookmarks_from_the_past := true:
	set(value):
		if show_bookmarks_from_the_past == value:
			return

		show_bookmarks_from_the_past = value
		_start_debounce_timer()

		EventBus.show_bookmarks_from_the_past_changed.emit()

@export var fade_ticked_off_todos := true:
	set(value):
		if fade_ticked_off_todos == value:
			return

		fade_ticked_off_todos = value
		_start_debounce_timer()

		EventBus.fade_ticked_off_todos_changed.emit()

@export var fade_non_today_dates := FadeNonTodayDates.PAST:
	set(value):
		if fade_non_today_dates == value:
			return

		fade_non_today_dates = value
		_start_debounce_timer()

		EventBus.fade_non_today_dates_changed.emit()

var bookmarks_due_today := 0:
	set(value):
		if bookmarks_due_today == value:
			return

		bookmarks_due_today = value
		_start_debounce_timer()

		EventBus.bookmarks_due_today_changed.emit()


func _enter_tree() -> void:
	get_window().wrap_controls = true  # Sadly, there is no ProjectSetting to enable this by default

	if OS.has_feature("editor"):
		settings_path = ProjectSettings.globalize_path("user://debug_settings.cfg")
	else:
		settings_path = ProjectSettings.globalize_path("user://settings.cfg")

	load_from_disk()


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	var debounce_timer := Timer.new()
	debounce_timer.name = "DebounceTimer"
	debounce_timer.wait_time = 6.0  # seconds
	debounce_timer.one_shot = true
	add_child(debounce_timer)


func _connect_signals() -> void:
	$DebounceTimer.timeout.connect(func():
		if OS.is_debug_build():
			print("[DEBUG] DebounceTimer Timed Out: Saving Settings...")
		save_to_disk()
	)


func _start_debounce_timer() -> void:
	if is_node_ready():
		if OS.is_debug_build():
			print("[DEBUG] Settings Save Requested: (Re)Starting DebounceTimer...")
		$DebounceTimer.start()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_to_disk()


func save_to_disk() -> void:
	var config := ConfigFile.new()

	config.load(settings_path)  # keep existing settings (if there are any)

	var exported_properties := Utils.get_exported_properties(self)
	for group in exported_properties:
		for property in exported_properties[group]:
			config.set_value(group, property, get(property))

	config.save(settings_path)

	if OS.is_debug_build():
		print("[DEBUG] Settings Saved to Disk!")


func load_from_disk() -> void:
	var config := ConfigFile.new()
	var error := config.load(settings_path)
	if not error:
		var exported_properties := Utils.get_exported_properties(self)
		for group in exported_properties:
			for property in exported_properties[group]:
				set(property, config.get_value(group, property, get(property)))

	if OS.is_debug_build():
		print("[DEBUG] Settings Restored From Disk!")
