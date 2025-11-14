extends Node

# As this script does not emit any signals itself, and is meant to be used as a
# global proxy for others, the "unused_singal" warning serves no purpose here.

@warning_ignore_start("unused_signal")
signal today_changed

signal search_screen_button_pressed

signal global_search_requested()
@warning_ignore_restore("unused_signal")
