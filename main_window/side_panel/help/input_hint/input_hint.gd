extends HBoxContainer


var description := "":
	set(value):
		description = value
		$Description.text = description


var key_binding : InputEvent:
	set(value):
		key_binding = value

		var split := key_binding.as_text().split("+")
		for i in split.size():
			var label = Label.new()
			add_child(label)

			label.text = _morph_key_notation(split[i]).to_upper()
			label.custom_minimum_size.x = 24
			label.theme_type_variation = "KeyBindingLabel"
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

			if i < split.size() - 1:
				var separator = Label.new()
				add_child(separator)

				separator.text = "+"
				separator.custom_minimum_size.x = 12
				separator.add_theme_font_size_override("font_size", 10)
				separator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _morph_key_notation(key) -> String:
	match key:
		"Minus":
			return "–"
		"Plus":
			return "+"
		"Up":
			return "🠉"
		"Right":
			return "🠊"
		"Down":
			return "🠋"
		"Left":
			return "🠈"
		_:
			return key
