extends Node

# FIXME: currently there is no @warning_ignore_all annotation, see:
# https://github.com/godotengine/godot-proposals/issues/5906

@warning_ignore("unused_signal")
signal today_changed
@warning_ignore("unused_signal")
signal dark_mode_changed(dark_mode)
@warning_ignore("unused_signal")
signal view_mode_changed(view_mode)
@warning_ignore("unused_signal")
signal current_day_changed(current_day)
@warning_ignore("unused_signal")
signal day_start_hour_offset_changed(shift)

@warning_ignore("unused_signal")
signal settings_button_pressed
@warning_ignore("unused_signal")
signal calendar_button_pressed
@warning_ignore("unused_signal")
signal search_screen_button_pressed
@warning_ignore("unused_signal")
signal capture_button_pressed
@warning_ignore("unused_signal")
signal bookmarks_button_pressed
@warning_ignore("unused_signal")
signal help_button_pressed

@warning_ignore("unused_signal")
signal overlay_closed

@warning_ignore("unused_signal")
signal todo_list_clicked
@warning_ignore("unused_signal")
signal search_query_changed

@warning_ignore("unused_signal")
signal bookmark_added(to_do)
@warning_ignore("unused_signal")
signal bookmark_text_changed(to_do, old_text)
@warning_ignore("unused_signal")
signal bookmark_removed(to_do)
