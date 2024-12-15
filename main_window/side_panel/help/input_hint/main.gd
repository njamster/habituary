extends HBoxContainer

var description := "":
	set(value):
		description = value
		$Description.text = description

var key_binding : InputEvent:
	set(value):
		key_binding = value
		$KeyBinding.text = key_binding.as_text().to_upper().replace("+", " + ")
