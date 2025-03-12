extends Node
class_name Tooltip


@export_multiline var text : String:
	set(value):
		text = value
		if get_child_count():
			_tooltip_label.text = value
			_tooltip_panel.size = Vector2.ZERO # shrink to content
			_position_tooltip()

@export var hide_text := false

@export var input_action : String

@export var hide_input_action := false

## When enabled, [member text] and [member input_action] are printed in one line, not two.
@export var is_dense := false

@export var disabled := false

@export var text_alignment := HORIZONTAL_ALIGNMENT_CENTER

@export_range(0.0, 0.0, 0.1, "suffix:seconds", "or_greater") var popup_delay := 0.5

enum PopupPosition {AUTOMATIC_HORIZONTAL, AUTOMATIC_VERTICAL, ABOVE, RIGHT, BELOW, LEFT}
@export var popup_position := PopupPosition.AUTOMATIC_HORIZONTAL

@export_range(0, 0, 1, "suffix:px", "or_greater") var gap_width := 8

@export var show_on_disabled_buttons := false

@onready var host := get_parent()

var _tooltip_panel : PanelContainer
var _tooltip_label : Label
var _hover_timer : Timer

var _contains_mouse_cursor := false


func _ready() -> void:
	_hover_timer = Timer.new()
	add_child(_hover_timer, true, Node.INTERNAL_MODE_FRONT)

	_hover_timer.one_shot = true
	_hover_timer.wait_time = popup_delay
	_hover_timer.timeout.connect(_spawn_panel)

	host.mouse_entered.connect(show_tooltip)
	host.mouse_exited.connect(hide_tooltip)

	if host is BaseButton:
		if not self.input_action:
			# try to grab input action from first shortcut event
			if host.shortcut and host.shortcut.events:
				self.input_action = host.shortcut.events[0].action

		host.pressed.connect(_on_press_or_toggle)
		host.toggled.connect(_on_press_or_toggle)

	get_tree().get_root().size_changed.connect(hide_tooltip)


func show_tooltip() -> void:
	_contains_mouse_cursor = true

	if disabled or (not text and not input_action):
		return

	if host is BaseButton and host.disabled and not show_on_disabled_buttons:
		return

	_hover_timer.start()


func hide_tooltip() -> void:
	_contains_mouse_cursor = false

	_hover_timer.stop()

	if get_child_count():
		_tooltip_panel.hide()
		_tooltip_panel.queue_free()


func _spawn_panel() -> void:
	# step 1: create panel
	_tooltip_panel = PanelContainer.new()
	add_child(_tooltip_panel)

	# Since this is not a Control node, it breaks the chain of automatic theme
	# inheritance, and we need to set the theme of the panel manually here.
	_tooltip_panel.theme = get_window().theme
	_tooltip_panel.theme_type_variation = "TooltipPanel"

	# step 2: create container
	var container = BoxContainer.new()
	_tooltip_panel.add_child(container)

	container.vertical = not is_dense

	# step 3: add tooltip label
	if not hide_text:
		_tooltip_label = Label.new()
		container.add_child(_tooltip_label)

		_tooltip_label.theme_type_variation = "TooltipLabel"

		_tooltip_label.text = text
		_tooltip_label.horizontal_alignment = self.text_alignment

	# step 4: add shortcut hint (optional)
	if not hide_input_action:
		if self.input_action:
			for action in self.input_action.split(","):
				if InputMap.has_action(action):
					var events := InputMap.action_get_events(action)
					if events:
						if container.has_node("ShortcutHint"):
							container.get_node("ShortcutHint").text += " / " + \
								events[0].as_text().to_upper().replace("+", " + ")
						else:
							var _shortcut_hint = Label.new()
							_shortcut_hint.name = "ShortcutHint"
							container.add_child(_shortcut_hint)

							_shortcut_hint.theme_type_variation = "TooltipLabel"
							_shortcut_hint.add_theme_font_size_override("font_size", 11)
							_shortcut_hint.modulate.a = 0.5

							_shortcut_hint.text = events[0].as_text().to_upper().replace("+", " + ")
							_shortcut_hint.horizontal_alignment = self.text_alignment
				else:
					push_warning("Unknown input action: '%s'" % action)

	# step 5: position tooltip
	_position_tooltip()


func _position_tooltip() -> void:
	# temporarily anchor tooltip at the top left corner of the parent node
	_tooltip_panel.global_position = host.global_position

	match self.popup_position:
		PopupPosition.AUTOMATIC_HORIZONTAL:
			if _tooltip_panel.global_position.x > 0.5 * get_window().size.x:
				_position_left()
			else:
				_position_right()
		PopupPosition.AUTOMATIC_VERTICAL:
			if _tooltip_panel.global_position.y > 0.5 * get_window().size.y:
				_position_above()
			else:
				_position_below()
		PopupPosition.ABOVE:
			_position_above()
		PopupPosition.RIGHT:
			_position_right()
		PopupPosition.BELOW:
			_position_below()
		PopupPosition.LEFT:
			_position_left()


func _position_above() -> void:
	_center_horizontally()
	_tooltip_panel.global_position.y -= _tooltip_panel.size.y + gap_width


func _position_below() -> void:
	_center_horizontally()
	_tooltip_panel.global_position.y += host.size.y + gap_width


func _center_horizontally() -> void:
	_tooltip_panel.global_position.x = clamp(
		_tooltip_panel.global_position.x + 0.5 * (host.size.x - _tooltip_panel.size.x),
		gap_width,
		get_window().size.x - _tooltip_panel.size.x - gap_width
	)


func _position_left() -> void:
	_center_vertically()
	_tooltip_panel.global_position.x -= _tooltip_panel.size.x + gap_width


func _position_right() -> void:
	_center_vertically()
	_tooltip_panel.global_position.x += host.size.x + gap_width


func _center_vertically() -> void:
	_tooltip_panel.global_position.y = clamp(
		_tooltip_panel.global_position.y + 0.5 * (host.size.y - _tooltip_panel.size.y),
		gap_width,
		get_window().size.y - _tooltip_panel.size.y - gap_width
	)


func _on_press_or_toggle(_toggled_on := false) -> void:
	if _hover_timer.is_stopped():
		# If the _hover_timer has already finished (i.e. the tooltip is visible), hide it
		# once the user clicks the button. It will only show again after moving the mouse
		# off of the button and back on and waiting for the _hover_timer to finish.
		hide_tooltip()
	elif _contains_mouse_cursor:
		# If the mouse remains on top of a button after being pressed and the _hover_timer
		# has not yet finished (i.e. there's no tooltip visible), reset the _hover_timer.
		# => While rapidly pressing a button, no tooltip will be shown!
		show_tooltip()


func _input(event: InputEvent) -> void:
	# Hide as soon as the user starts typing or clicks anywhere
	if event is InputEventKey or event is InputEventMouseButton:
		hide_tooltip()
