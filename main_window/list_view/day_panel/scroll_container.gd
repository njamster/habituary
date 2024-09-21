extends ScrollContainer

signal scrolled

const TODO_ITEM_HEIGHT := 40 # pixels


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_scroll_one_item_down()
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_scroll_one_item_up()
			accept_event()

		if vertical_scroll_mode == SCROLL_MODE_SHOW_NEVER:
			if event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
				_scroll_one_item_down()
				accept_event()
			elif event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
				_scroll_one_item_up()
				accept_event()


func _scroll_one_item_down() -> void:
	if self.scroll_vertical == 0:
		# scroll two (!) items down, since the ScrollUpButton will appear above
		self.scroll_vertical += 2 * TODO_ITEM_HEIGHT
	else:
		# scroll one item down
		self.scroll_vertical += TODO_ITEM_HEIGHT


func _scroll_one_item_up() -> void:
	if self.scroll_vertical == 2 * TODO_ITEM_HEIGHT:
		# scroll two (!) items up, since the ScrollUpButton will disappear above
		self.scroll_vertical = 0
	else:
		# scroll one item down
		self.scroll_vertical -= TODO_ITEM_HEIGHT


func _set(property, _value) -> bool:
	if property == "scroll_vertical":
		scrolled.emit.call_deferred()
	return false
