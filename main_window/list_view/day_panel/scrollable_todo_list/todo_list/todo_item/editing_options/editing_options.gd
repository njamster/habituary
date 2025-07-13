extends VBoxContainer


@onready var to_do: ToDoItem

var _shrink_threshold: int


func _ready() -> void:
	var parent := get_parent()
	while parent is not ToDoItem and parent != null:
		parent = parent.get_parent()
	to_do = parent

	_set_initial_state()
	_connect_signals()


func _set_initial_state() -> void:
	# Temporarily switch to the longest version of the respective button labels:
	%Bookmark.text = "Remove Bookmark"
	# Measure the minimum size of the editing options (i.e. *with* labels). This
	# will act as the threshold at which all labels in the editing options will
	# automatically be hidden to save horizontal space:
	_shrink_threshold = $PanelContainer.get_combined_minimum_size().x

	update()

	_on_editing_options_resized()
	_on_dark_mode_changed()


func _connect_signals() -> void:
	Settings.dark_mode_changed.connect(_on_dark_mode_changed)

	$PanelContainer.resized.connect(_on_editing_options_resized)

	%Bold.toggled.connect(_on_bold_toggled)
	%Italic.toggled.connect(_on_italic_toggled)
	%TextColor.gui_input.connect(_on_text_color_gui_input)

	%Bookmark.toggled.connect(_on_bookmark_toggled)
	%Delete.pressed.connect(_on_delete_pressed)


func update() -> void:
	update_bold()
	update_italic()
	update_text_color()
	update_bookmark()


func update_bold() -> void:
	%Bold.button_pressed = to_do.is_bold

	if %Bold.button_pressed:
		%Bold/Tooltip.text = "Undo Bold"
	else:
		%Bold/Tooltip.text = "Make Bold"


func update_italic() -> void:
	%Italic.button_pressed = to_do.is_italic

	if %Italic.button_pressed:
		%Italic/Tooltip.text = "Undo Italic"
	else:
		%Italic/Tooltip.text = "Make Italic"


func update_text_color() -> void:
	if to_do.text_color_id:
		var color = Settings.to_do_text_colors[to_do.text_color_id - 1]
		%TextColor.get("theme_override_styles/panel").bg_color = color
		%TextColor.get("theme_override_styles/panel").draw_center = true
	else:
		%TextColor.get("theme_override_styles/panel").draw_center = false


func update_bookmark() -> void:
	%Bookmark.button_pressed = to_do.is_bookmarked

	if %Bookmark.button_pressed:
		%Bookmark.text = %Bookmark.text.replace("Add", "Remove")
	else:
		%Bookmark.text = %Bookmark.text.replace("Remove", "Add")
	%Bookmark/Tooltip.text = %Bookmark.text

	# FIXME: temporary band-aid fix, until it's possible to bookmark to-dos in
	# the capture panel as well (or it's decided that's not required at all)
	if not to_do.date:
		%Bookmark.hide()
		%Delete.size_flags_horizontal = SIZE_SHRINK_END + SIZE_EXPAND
	else:
		%Bookmark.show()
		%Delete.size_flags_horizontal = SIZE_SHRINK_END


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


func _on_bold_toggled(toggled_on: bool) -> void:
	to_do.is_bold = toggled_on


func _on_italic_toggled(toggled_on: bool) -> void:
	to_do.is_italic = toggled_on


func _on_text_color_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT, MOUSE_BUTTON_WHEEL_UP:
				to_do.text_color_id += 1
			MOUSE_BUTTON_MIDDLE:
				to_do.text_color_id  = 0
			MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_WHEEL_DOWN:
				to_do.text_color_id -= 1
			_:
				return  # early, i.e. ignore the input

		get_viewport().set_input_as_handled()


func _on_bookmark_toggled(toggled_on: bool) -> void:
	to_do.is_bookmarked = toggled_on

	if to_do.is_bookmarked:
		EventBus.bookmark_added.emit(to_do)
	else:
		EventBus.bookmark_removed.emit(to_do)


func _on_delete_pressed() -> void:
	to_do.delete()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_bold", false, true):
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


func _on_dark_mode_changed() -> void:
	if Settings.dark_mode:
		%TextColor.get("theme_override_styles/panel").border_color = Color("#D8DEE9")
	else:
		%TextColor.get("theme_override_styles/panel").border_color = Color("#4C566A")
