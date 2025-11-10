class_name BetterButton
extends Button


## Enable this, if pressing this button triggers a change in the current scene
## that might result in a different UI element being underneath the mouse cursor
## afterwards.[br][br]
## Otherwise, the cursor will only be updated after [i]moving[/i] the mouse.
@export var update_mouse_cursor_after_button_press := true


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	#region Local Signals
	if update_mouse_cursor_after_button_press:
		pressed.connect(_update_mouse_cursor_state)
		toggled.connect(_update_mouse_cursor_state.unbind(1))
	#endregion


func _update_mouse_cursor_state() -> void:
	if is_inside_tree():
		get_viewport().update_mouse_cursor_state.call_deferred()
