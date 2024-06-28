@tool
extends VBoxContainer

@export var date : Date:
	set(value):
		date = value
		_update_store_path()
		if is_inside_tree():
			_update_header()
			if value:
				date.changed.connect(_update_header)
				date.changed.connect(_update_store_path)

var store_path := ""




func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(date != null, "You must provide a date in order for this node to work!")

	_update_header()
	_update_store_path()

	if not Engine.is_editor_hint():
		EventBus.new_day_started.connect(_apply_date_relative_formating)


func _update_header() -> void:
	if date:
		%Date.text = date.format("DD MMM YYYY")
		%Weekday.text = date.format("dddd")
	else:
		%Date.text = "DD MMM YYYY"
		%Weekday.text = "WEEKDAY"
	_apply_date_relative_formating()


func _update_store_path() -> void:
	store_path = "%s/%s.txt" % [
		Settings.store_path,
		self.date.format(Settings.date_format_save)
]


func _apply_date_relative_formating() -> void:
	if date:
		var day_difference := date.day_difference_to(DayTimer.today)

		if day_difference < 0:
			# date is in the past
			modulate.a = 0.4
			%Weekday.remove_theme_color_override("font_color")
		elif day_difference == 0:
			# date is today
			modulate.a = 1.0
			%Weekday.add_theme_color_override("font_color", Color("88c0d0"))
		else:
			# date is in the future
			modulate.a = 1.0
			%Weekday.remove_theme_color_override("font_color")
	else:
		# reset formatting
		modulate.a = 1.0
		%Weekday.remove_theme_color_override("font_color")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not date:
		warnings.append("You must provide a date in order for this node to work!")
	return warnings


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.is_in_group("todo_item")


func _drop_data(at_position: Vector2, data: Variant) -> void:
	%TodoList._drop_data(at_position - $ScrollContainer.position, data)


func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		if event.pressed:
			get_viewport().set_input_as_handled()
			Settings.current_day = date


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		if event.pressed:
			%TodoList.add_todo(event.global_position)


func save_to_disk() -> void:
	if %TodoList.has_items():
		var file := FileAccess.open(store_path, FileAccess.WRITE)
		%TodoList.save_to_disk(file)
	elif FileAccess.file_exists(store_path):
		DirAccess.remove_absolute(store_path)


func load_from_disk() -> void:
	if FileAccess.file_exists(store_path):
		%TodoList.load_from_disk(FileAccess.open(store_path, FileAccess.READ))
