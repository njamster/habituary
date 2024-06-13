extends Control

const DAY_PANEL := preload("res://day_panel/day_panel.tscn")

var today := Date.new(Time.get_date_dict_from_system())

var current_day : Date:
	set(value):
		current_day = value
		if is_inside_tree():
			# remove old panels
			for child in %Lists.get_children():
				%Lists.remove_child(child)
			# add new panels
			for i in days_shown:
				var day_panel := DAY_PANEL.instantiate()
				day_panel.day = current_day.add_days(i)
				%Lists.add_child(day_panel)

var days_shown := 7:
	set(value):
		days_shown = value
		if is_inside_tree():
			# remove old panels
			for child in %Lists.get_children():
				%Lists.remove_child(child)
			# add new panels
			for i in days_shown:
				var day_panel := DAY_PANEL.instantiate()
				day_panel.day = current_day.add_days(i)
				%Lists.add_child(day_panel)


func _ready() -> void:
	for day_button in %Buttons.get_children():
		day_button.pressed.connect(_on_day_button_pressed.bind(day_button))


	current_day = today
	days_shown = days_shown


func _on_day_button_pressed(button: Button):
	for day_button in %Buttons.get_children():
		day_button.flat = (day_button != button)
	days_shown = int(button.text)


func _on_prev_week_pressed() -> void:
	current_day = current_day.add_days(-7)


func _on_prev_day_pressed() -> void:
	current_day = current_day.add_days(-1)


func _on_today_pressed() -> void:
	current_day = today


func _on_next_day_pressed() -> void:
	current_day = current_day.add_days(1)


func _on_next_week_pressed() -> void:
	current_day = current_day.add_days(7)
