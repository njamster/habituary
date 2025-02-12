extends Node


signal to_do_text_colors_changed
signal current_day_changed
signal view_mode_changed
signal view_mode_cap_changed
signal day_start_changed
signal dark_mode_changed
signal search_query_changed
signal side_panel_changed
signal show_bookmarks_from_the_past_changed
signal hide_ticked_off_todos_changed
signal fade_ticked_off_todos_changed
signal fade_non_today_dates_changed
signal bookmarks_due_today_changed


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


const MIN_UI_SCALE_FACTOR := 1.00
const MAX_UI_SCALE_FACTOR := 3.00


var DEFAULT_TO_DO_TEXT_COLORS := [
	"#A3BE8C",
	"#EBCB8B",
	"#D08770",
	"#B48EAD",
	"#BF616A",
]

@export var to_do_text_colors := DEFAULT_TO_DO_TEXT_COLORS:
	set(value):
		if to_do_text_colors == value or value.size() != 5:
			return

		to_do_text_colors = value
		_start_debounce_timer()

		to_do_text_colors_changed.emit()

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

		current_day_changed.emit()

var previous_view_mode

@export var view_mode := 3:
	set(value):
		if view_mode == value:
			return

		if previous_view_mode != view_mode:
			previous_view_mode = null

		view_mode = value
		_start_debounce_timer()

		view_mode_changed.emit()

var view_mode_cap := 7:
	set(value):
		if view_mode_cap == value:
			return

		view_mode_cap = value

		view_mode_cap_changed.emit()

var previous_day

var current_day := DayTimer.today:
	set(value):
		if current_day.day_difference_to(value) == 0:
			return

		if previous_day != current_day:
			previous_day = null

		current_day = value

		current_day_changed.emit()

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

		day_start_changed.emit()

@export var day_start_minute_offset := 0:
	set(value):
		if day_start_minute_offset == value:
			return

		day_start_minute_offset = value
		_start_debounce_timer()

		day_start_changed.emit()

@export var dark_mode := true:
	set(value):
		if dark_mode == value:
			return

		dark_mode = value
		_start_debounce_timer()

		if dark_mode:
			# NOTE: CACHE_MODE_IGNORE *must* be used here, as this is set as the
			# custom theme in the Project Settings. Without it, the custom theme
			# is reused and the setters of its export variables won't run.
			get_window().theme = ResourceLoader.load(
				"res://theme/dark_theme.tres",
				"",
				ResourceLoader.CACHE_MODE_IGNORE
			)
		else:
			# NOTE: Since the light variant isn't used as the custom theme (see
			# note above), it could technically apply CACHE_MODE_REUSE. However,
			# due to this, it should not be present in the cache anyway!
			get_window().theme = ResourceLoader.load(
				"res://theme/light_theme.tres",
				"",
				ResourceLoader.CACHE_MODE_IGNORE
			)

		dark_mode_changed.emit()

var search_query := "":
	set(value):
		if search_query == value:
			return

		search_query = value

		search_query_changed.emit()

@export var side_panel := SidePanelState.HIDDEN:
	set(value):
		if side_panel == value:
			return

		side_panel = value
		_start_debounce_timer()

		side_panel_changed.emit()

@export var show_bookmarks_from_the_past := true:
	set(value):
		if show_bookmarks_from_the_past == value:
			return

		show_bookmarks_from_the_past = value
		_start_debounce_timer()

		show_bookmarks_from_the_past_changed.emit()

@export var hide_ticked_off_todos := false:
	set(value):
		if hide_ticked_off_todos == value:
			return

		hide_ticked_off_todos = value
		_start_debounce_timer()

		hide_ticked_off_todos_changed.emit()

@export var fade_ticked_off_todos := true:
	set(value):
		if fade_ticked_off_todos == value:
			return

		fade_ticked_off_todos = value
		_start_debounce_timer()

		fade_ticked_off_todos_changed.emit()

@export var fade_non_today_dates := FadeNonTodayDates.PAST:
	set(value):
		if fade_non_today_dates == value:
			return

		fade_non_today_dates = value
		_start_debounce_timer()

		fade_non_today_dates_changed.emit()

var bookmarks_due_today := 0:
	set(value):
		if bookmarks_due_today == value:
			return

		bookmarks_due_today = value
		_start_debounce_timer()

		bookmarks_due_today_changed.emit()

@export var ui_scale_factor := 1.0:
	set(value):
		if ui_scale_factor == value:
			return

		ui_scale_factor = clampf(
			snappedf(value, 0.01),
			MIN_UI_SCALE_FACTOR,
			MAX_UI_SCALE_FACTOR
		)
		_start_debounce_timer()

		if not is_node_ready():
			await self.ready  # while loading from disk

		get_window().content_scale_factor = ui_scale_factor

		# FIXME: I don't understand yet why, but somehow waiting one frame here
		# is crucial forscale factor changes during runtime work properly?!
		await get_tree().process_frame

		# HACK: For some reason, changing the window's content_scale_factor does
		# affect the result of get_contents_minimum_size in a weird way, making
		# it smaller(!) the larger the scale_factor becomes.
		# That's why I reimplement get_contents_minimum_size here, but without
		# taking the control's position into account (which appears to change
		# with the scale_factor). I believe this will lead to wrong results if
		# the control's position is *not* equal to (0, 0), but otherwise will
		# work correctly (which is sufficient for this project).
		var minimum_content_size := Vector2.ZERO
		for child in get_window().get_children():
			if child is Control:
				minimum_content_size = minimum_content_size.max(
					child.get_combined_minimum_size()
				)

		get_window().min_size = minimum_content_size * ui_scale_factor

@export var is_maximized: bool:
	set(value):
		if is_maximized == value:
			return

		if value == true:
			get_window().mode = Window.MODE_MAXIMIZED
		else:
			get_window().mode = Window.MODE_WINDOWED

		_start_debounce_timer()
	get():
		return get_window().mode == Window.MODE_MAXIMIZED


@export var is_fullscreen: bool:
	set(value):
		if is_fullscreen == value:
			return

		if value == true:
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED

		_start_debounce_timer()
	get():
		return get_window().mode == Window.MODE_FULLSCREEN || \
			get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN


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
