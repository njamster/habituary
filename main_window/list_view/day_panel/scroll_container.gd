extends ScrollContainer

signal scrolled


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			self.scroll_vertical = max(self.scroll_vertical - 40, 0)
			accept_event()

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			self.scroll_vertical = min(
				self.scroll_vertical + 40,
				get_child(0).size.y - self.size.y - 39
			)
			accept_event()

		if vertical_scroll_mode == SCROLL_MODE_SHOW_NEVER:
			if event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
				self.scroll_vertical = max(self.scroll_vertical - 40, 0)
				accept_event()

			if event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
				self.scroll_vertical = min(
					self.scroll_vertical + 40,
					get_child(0).size.y - self.size.y - 39
				)
				accept_event()


func _set(property, _value) -> bool:
	if property == "scroll_vertical":
		scrolled.emit.call_deferred()
	return false
