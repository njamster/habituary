extends Node
class_name Tooltip

@export_multiline var text : String:
	set(value):
		text = value
		if get_child_count():
			_tooltip_label.text = value
			_tooltip_panel.size = Vector2.ZERO # shrink to content
			_position_tooltip()

@export var text_alignment : HorizontalAlignment

@export_range(0.0, 0.0, 0.1, "suffix:seconds", "or_greater") var popup_delay := 0.5

enum PopupPosition {AUTOMATIC_HORIZONTAL, AUTOMATIC_VERTICAL, ABOVE, RIGHT, BELOW, LEFT}
@export var popup_position := PopupPosition.AUTOMATIC_HORIZONTAL

@export_range(0, 0, 1, "suffix:px", "or_greater") var gap_width := 8

@export var show_on_disabled_buttons := false

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

	get_parent().mouse_entered.connect(show_tooltip)
	get_parent().mouse_exited.connect(hide_tooltip)

	if get_parent() is BaseButton:
		get_parent().pressed.connect(func():
			if _contains_mouse_cursor and not get_child_count():
				_hover_timer.start(popup_delay)
		)

	get_tree().get_root().size_changed.connect(hide_tooltip)


func show_tooltip() -> void:
	_contains_mouse_cursor = true

	if not text:
		return

	if get_parent() is BaseButton and get_parent().disabled and not show_on_disabled_buttons:
		return

	_hover_timer.start()


func hide_tooltip() -> void:
	_contains_mouse_cursor = false

	_hover_timer.stop()

	if get_child_count():
		remove_child(_tooltip_panel)
		_tooltip_panel.queue_free()


func _spawn_panel() -> void:
	# step 1: create panel
	_tooltip_panel = PanelContainer.new()
	add_child(_tooltip_panel)

	_tooltip_panel.theme_type_variation = "TooltipPanel"

	# step 2: create label
	_tooltip_label = Label.new()
	_tooltip_panel.add_child(_tooltip_label)

	_tooltip_label.theme_type_variation = "TooltipLabel"

	_tooltip_label.text = text
	_tooltip_label.horizontal_alignment = self.text_alignment

	# step 3: position tooltip
	_position_tooltip()


func _position_tooltip() -> void:
	# temporarily anchor tooltip at the top left corner of the parent node
	_tooltip_panel.global_position = get_parent().global_position

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
	_tooltip_panel.global_position.y += get_parent().size.y + gap_width


func _center_horizontally() -> void:
	_tooltip_panel.global_position.x = clamp(
		_tooltip_panel.global_position.x + 0.5 * (get_parent().size.x - _tooltip_panel.size.x),
		gap_width,
		get_window().size.x - _tooltip_panel.size.x - gap_width
	)


func _position_left() -> void:
	_center_vertically()
	_tooltip_panel.global_position.x -= _tooltip_panel.size.x + gap_width


func _position_right() -> void:
	_center_vertically()
	_tooltip_panel.global_position.x += get_parent().size.x + gap_width


func _center_vertically() -> void:
	_tooltip_panel.global_position.y = clamp(
		_tooltip_panel.global_position.y + 0.5 * (get_parent().size.y - _tooltip_panel.size.y),
		gap_width,
		get_window().size.y - _tooltip_panel.size.y - gap_width
	)
