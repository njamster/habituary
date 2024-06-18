extends HBoxContainer


func _on_previous_week_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(-7)


func _on_previous_day_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(-1)


func _on_today_pressed() -> void:
	Settings.current_day = Date.new(Time.get_date_dict_from_system())


func _on_next_day_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(1)


func _on_next_week_pressed() -> void:
	Settings.current_day = Settings.current_day.add_days(7)
