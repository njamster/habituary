extends VBoxContainer


var _shrink_threshold: int


func _ready() -> void:
	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	# Temporarily switch to the longest version of the respective button labels:
	%Bookmark.text = "Remove Bookmark"
	%Delete.text = "Delete Heading"
	# Measure the minimum size of the editing options (i.e. *with* labels). This
	# will act as the threshold at which all labels in the editing options will
	# automatically be hidden to save horizontal space:
	_shrink_threshold = $PanelContainer.get_combined_minimum_size().x

	update()

	_on_editing_options_resized()

	# FIXME: temporary band-aid fix, until it's possible to bookmark to-dos in
	# the capture panel as well
	if not get_parent().date:
		%Bookmark.hide()
		%Delete.size_flags_horizontal += SIZE_EXPAND


func _connect_signals() -> void:
	$PanelContainer.resized.connect(_on_editing_options_resized)

	%Heading.toggled.connect(_on_heading_toggled)
	%Bold.toggled.connect(_on_bold_toggled)
	%Italic.toggled.connect(_on_italic_toggled)
	%TextColor.gui_input.connect(_on_text_color_gui_input)

	%Bookmark.toggled.connect(_on_bookmark_toggled)
	%Delete.pressed.connect(_on_delete_pressed)


func update() -> void:
	update_indentation()
	update_heading()
	update_bold()
	update_italic()
	update_text_color()
	update_bookmark()


func update_indentation() -> void:
	$Indentation.add_theme_constant_override(
		"margin_left",
		get_parent().get_node("%Indentation").custom_minimum_size.x
	)


func update_heading() -> void:
	%Heading.button_pressed = get_parent().is_heading

	if %Heading.button_pressed:
		%Heading/Tooltip.text = "Undo Heading"
		%Delete.text = "Delete Heading"
	else:
		%Heading/Tooltip.text = "Make Heading"
		%Delete.text = "Delete To-Do"
	%Delete/Tooltip.text = %Delete.text


func update_bold() -> void:
	%Bold.button_pressed = get_parent().is_bold

	if %Bold.button_pressed:
		%Bold/Tooltip.text = "Undo Bold"
	else:
		%Bold/Tooltip.text = "Make Bold"


func update_italic() -> void:
	%Italic.button_pressed = get_parent().is_italic

	if %Italic.button_pressed:
		%Italic/Tooltip.text = "Undo Italic"
	else:
		%Italic/Tooltip.text = "Make Italic"


func update_text_color() -> void:
	if get_parent().text_color_id:
		var color = Settings.to_do_text_colors[ get_parent().text_color_id - 1]
		%TextColor.get("theme_override_styles/panel").bg_color = color
		%TextColor.get("theme_override_styles/panel").draw_center = true
	else:
		%TextColor.get("theme_override_styles/panel").draw_center = false


func update_bookmark() -> void:
	%Bookmark.button_pressed = get_parent().is_bookmarked

	if %Bookmark.button_pressed:
		%Bookmark.text = %Bookmark.text.replace("Add", "Remove")
	else:
		%Bookmark.text = %Bookmark.text.replace("Remove", "Add")
	%Bookmark/Tooltip.text = %Bookmark.text


func _on_editing_options_resized() -> void:
	if $PanelContainer.size.x <= _shrink_threshold:
		%FormatLabel.hide()

		%Delete.clip_text = true
		%Delete/Tooltip.hide_text = false

		%Bookmark.clip_text = true
		%Bookmark/Tooltip.hide_text = false
	else:
		%FormatLabel.show()

		%Delete.clip_text = false
		%Delete/Tooltip.hide_text = true

		%Bookmark.clip_text = false
		%Bookmark/Tooltip.hide_text = true


func _on_heading_toggled(toggled_on: bool) -> void:
	get_parent().is_heading = toggled_on


func _on_bold_toggled(toggled_on: bool) -> void:
	get_parent().is_bold = toggled_on


func _on_italic_toggled(toggled_on: bool) -> void:
	get_parent().is_italic = toggled_on


func _on_text_color_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT, MOUSE_BUTTON_WHEEL_UP:
				get_parent().text_color_id += 1
			MOUSE_BUTTON_MIDDLE:
				get_parent().text_color_id  = 0
			MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_WHEEL_DOWN:
				get_parent().text_color_id -= 1
			_:
				return  # early, i.e. ignore the input

		get_viewport().set_input_as_handled()
		%TextColor/Tooltip.hide_tooltip()


func _on_bookmark_toggled(toggled_on: bool) -> void:
	get_parent().is_bookmarked = toggled_on

	if get_parent().is_bookmarked:
		EventBus.bookmark_added.emit(get_parent())
	else:
		EventBus.bookmark_removed.emit(get_parent())


func _on_delete_pressed() -> void:
	get_parent().delete()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_heading", false, true):
		%Heading.button_pressed = not %Heading.button_pressed
	elif event.is_action_pressed("toggle_heading", true, true):
		pass  # consume echo events without doing anything
	elif event.is_action_pressed("toggle_bold", false, true):
		%Bold.button_pressed = not %Bold.button_pressed
	elif event.is_action_pressed("toggle_bold", true, true):
		pass  # consume echo events without doing anything
	elif event.is_action_pressed("toggle_italic", false, true):
		%Italic.button_pressed = not %Italic.button_pressed
	elif event.is_action_pressed("toggle_italic", true, true):
		pass  # consume echo events without doing anything
	elif event.is_action_pressed("toggle_bookmark", false, true):
		%Bookmark.button_pressed = not %Bookmark.button_pressed
	elif event.is_action_pressed("toggle_bookmark", true, true):
		pass  # consume echo events without doing anything
	elif event.is_action_pressed("delete_todo", false, true):
		_on_delete_pressed()
	elif event.is_action_pressed("delete_todo", true, true):
		pass  # consume echo events without doing anything
	else:
		return # early, i.e. ignore the input

	accept_event()
