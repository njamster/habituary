extends TextureRect

enum Modes {UP, DOWN}
@export var mode := Modes.UP

@onready var SCROLL_CONTAINER := $"../ScrollContainer"
@onready var SCROLL_CONTAINER_CONTENT := SCROLL_CONTAINER.get_child(0)


func _ready() -> void:
	self.hide()

	SCROLL_CONTAINER.resized.connect(_update_button)
	SCROLL_CONTAINER_CONTENT.resized.connect(_update_button)

	SCROLL_CONTAINER.scrolled.connect(_update_button)

	_update_button.call_deferred()


func _update_button() -> void:
	var items_out_of_view := 0

	if mode == Modes.UP:
		items_out_of_view = SCROLL_CONTAINER.scroll_vertical / SCROLL_CONTAINER.TODO_ITEM_HEIGHT
		if items_out_of_view == 1:
			if self.visible:
				# hide the button, freeing up space to display the last remaining to-do
				SCROLL_CONTAINER._scroll_one_item_up.call_deferred(false)
				self.hide()
				return
			else:
				# show the button, occupying the space of one previously visible to-do
				SCROLL_CONTAINER._scroll_one_item_down.call_deferred(false)
				items_out_of_view += 1
				self.show()
		%Text.text = "%d more to-dos above" % items_out_of_view
	else:
		var max_scroll_offset = max(SCROLL_CONTAINER_CONTENT.size.y - SCROLL_CONTAINER.size.y, 0)
		items_out_of_view = (max_scroll_offset - SCROLL_CONTAINER.scroll_vertical) / SCROLL_CONTAINER.TODO_ITEM_HEIGHT
		if items_out_of_view == 1:
			if self.visible:
				# hide the button, freeing up space to display the last remaining to-do
				self.hide()
				return
			else:
				# show the button, occupying the space of one previously visible to-do
				items_out_of_view += 1
				self.show()
		%Text.text = "%d more to-dos below" % items_out_of_view

	self.visible = (items_out_of_view > 0)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if mode == Modes.UP:
			SCROLL_CONTAINER._scroll_one_item_up()
		else:
			SCROLL_CONTAINER._scroll_one_item_down()
