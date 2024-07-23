extends PanelContainer


func _enter_tree() -> void:
	# See: https://github.com/godotengine/godot/issues/83546#issuecomment-1856927502
	# Without this line (or a custom_minimum_size for the label), the autowrapping will blow up the
	# vertical size of the panel. This can (as of now) only be done via code, not in the editor.
	$VBox/VBox1/Explanation.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)


func _on_visibility_changed() -> void:
	if visible:
		%StorePath/Path.text = Settings.store_path

		%TodayPosition/Options.clear()
		for option_name in Settings.TodayPosition:
			var option_id : int = Settings.TodayPosition[option_name]
			%TodayPosition/Options.add_item(option_name.capitalize(), option_id)
			if option_id == Settings.today_position:
				%TodayPosition/Options.select(option_id)
				_on_options_item_selected(option_id)

		%Close.grab_focus()


func _on_options_item_selected(index: int) -> void:
	Settings.today_position = Settings.TodayPosition[Settings.TodayPosition.keys()[index]]
	match index:
		Settings.TodayPosition.LEFTMOST:
			%TodayPosition.get_node("../Explanation").text = \
				"The current day will be displayed at the leftmost position of the list view."
		Settings.TodayPosition.SECOND_PLACE:
			%TodayPosition.get_node("../Explanation").text = \
				"The current day will be displayed at the second position of the list view."
		Settings.TodayPosition.CENTERED:
			%TodayPosition.get_node("../Explanation").text = \
				"The current day will be displayed at the center position of the list view."
		_:
			%TodayPosition.get_node("../Explanation").text = ""


func _on_close_pressed() -> void:
	get_parent().close_overlay()
