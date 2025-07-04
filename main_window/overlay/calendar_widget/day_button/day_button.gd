extends Button
class_name DayButton

var associated_day : Date


func _init(date : Date) -> void:
	associated_day = date

	self.text = str(date.day)
	self.focus_mode = Control.FOCUS_NONE
	self.custom_minimum_size = Vector2(28, 28)
	self.theme_type_variation = "CalendarWidget_DayButton"
	self.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var tooltip := Tooltip.new()
	tooltip.text = "Click to jump to this date"
	tooltip.popup_delay = 1.5
	add_child(tooltip)
