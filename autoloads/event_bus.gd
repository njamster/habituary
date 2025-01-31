extends Node

# FIXME: currently there is no @warning_ignore_all annotation, see:
# https://github.com/godotengine/godot-proposals/issues/5906

@warning_ignore("unused_signal")
signal today_changed

@warning_ignore("unused_signal")
signal calendar_button_pressed
@warning_ignore("unused_signal")
signal search_screen_button_pressed

@warning_ignore("unused_signal")
signal overlay_closed

@warning_ignore("unused_signal")
signal todo_list_clicked

@warning_ignore("unused_signal")
signal bookmark_added(to_do)
@warning_ignore("unused_signal")
signal bookmark_changed(to_do, old_date, old_index)
@warning_ignore("unused_signal")
signal bookmark_removed(to_do)
@warning_ignore("unused_signal")
signal bookmark_jump_requested(date, line_number)
