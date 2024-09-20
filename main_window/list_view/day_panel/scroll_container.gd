extends ScrollContainer

signal scrolled


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if self.scroll_vertical <= 80:
				# scroll two items up (since the ScrollUpButton will disappear)
				self.scroll_vertical = 0
			else:
				# scroll one item up
				self.scroll_vertical -= 40
			accept_event()

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if self.scroll_vertical == 0:
				# scroll two items down (since the ScrollUpButton will appear)
				self.scroll_vertical += 80
			elif self.scroll_vertical < get_child(0).size.y - self.size.y - 80:
				# scroll one item down
				self.scroll_vertical += 40
			else:
				# scroll two items down (since the ScrollDownButton will disappear)
				self.scroll_vertical = get_child(0).size.y - self.size.y
			accept_event()

		if vertical_scroll_mode == SCROLL_MODE_SHOW_NEVER:
			if event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
				if self.scroll_vertical <= 80:
					# scroll two items up (since the ScrollUpButton will disappear)
					self.scroll_vertical = 0
				else:
					# scroll one item up
					self.scroll_vertical -= 40
				accept_event()

			if event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
				if self.scroll_vertical == 0:
					# scroll two items down (since the ScrollUpButton will appear)
					self.scroll_vertical += 80
				elif self.scroll_vertical < get_child(0).size.y - self.size.y - 80:
					# scroll one item down
					self.scroll_vertical += 40
				else:
					# scroll two items down (since the ScrollDownButton will disappear)
					self.scroll_vertical = get_child(0).size.y - self.size.y
				accept_event()


func _set(property, _value) -> bool:
	if property == "scroll_vertical":
		scrolled.emit.call_deferred()
	return false
