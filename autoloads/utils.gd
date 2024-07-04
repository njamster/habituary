extends Node


func press_button_with_visual_feedback(button : Button) -> void:
	button.toggle_mode = true
	button.button_pressed = true
	button.pressed.emit()
	await get_tree().create_timer(
		ProjectSettings.get_setting("gui/timers/button_shortcut_feedback_highlight_time")
	).timeout
	if is_instance_valid(button):
		button.button_pressed = false
		button.toggle_mode = false
