extends Node

# As this script does not emit any signals itself, and is meant to be used as a
# global proxy for others, the "unused_singal" warning serves no purpose here.

@warning_ignore_start("unused_signal")
signal today_changed

signal calendar_button_pressed
signal search_screen_button_pressed

signal overlay_closed

signal todo_list_clicked

signal bookmark_added(to_do)
signal bookmark_changed(to_do, old_date, old_index)
signal bookmark_indicator_clicked(date, index)
signal bookmark_removed(to_do)
signal bookmark_jump_requested(date, line_number)

signal global_search_requested()
signal instant_save_requested(date)
signal saved_search_update_requested(query)
@warning_ignore_restore("unused_signal")
