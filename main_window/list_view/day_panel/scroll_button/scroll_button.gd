extends TextureRect

enum Modes {UP, DOWN}
@export var mode := Modes.UP

@onready var SCROLL_CONTAINER := $"../ScrollContainer"
@onready var SCROLL_CONTAINER_CONTENT := SCROLL_CONTAINER.get_child(0)


func _ready() -> void:
	SCROLL_CONTAINER.resized.connect(_update_button)
	SCROLL_CONTAINER_CONTENT.resized.connect(_update_button)

	SCROLL_CONTAINER.scrolled.connect(_update_button)


func _update_button() -> void:
	var items_out_of_view := 0

	if mode == Modes.UP:
		items_out_of_view = SCROLL_CONTAINER.scroll_vertical / SCROLL_CONTAINER.TODO_ITEM_HEIGHT

		if items_out_of_view > 1:
			%Text.text = "%d more to-dos above" % items_out_of_view
			self.show()
		else:
			self.hide()
	else:
		items_out_of_view = (SCROLL_CONTAINER_CONTENT.size.y - SCROLL_CONTAINER.size.y - SCROLL_CONTAINER.scroll_vertical) / SCROLL_CONTAINER.TODO_ITEM_HEIGHT

		if items_out_of_view > 0:
			%Text.text = "%d more to-dos below" % items_out_of_view
			self.show()
		else:
			self.hide()



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if mode == Modes.UP:
			SCROLL_CONTAINER._scroll_one_item_up()
		else:
			SCROLL_CONTAINER._scroll_one_item_down()
