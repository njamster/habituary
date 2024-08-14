extends PanelContainer

const X_OFFSET := +8 # pixels
const Y_OFFSET := -3 # pixels


func _enter_tree() -> void:
	get_parent().item_rect_changed.connect(update_position)
	update_position()


func update_position() -> void:
	global_position = get_parent().global_position + Vector2(
		get_parent().get_node("%Content").position.x + X_OFFSET,
		get_parent().get_node("%Content").position.y - size.y + Y_OFFSET
	)


func _ready() -> void:
	%Heading.button_pressed = get_parent().is_heading
	%Bold.button_pressed = get_parent().is_bold
	%Italic.button_pressed = get_parent().is_italic


func _on_heading_toggled(toggled_on: bool) -> void:
	get_parent().is_heading = toggled_on


func _on_bold_toggled(toggled_on: bool) -> void:
	get_parent().is_bold = toggled_on


func _on_italic_toggled(toggled_on: bool) -> void:
	get_parent().is_italic = toggled_on
