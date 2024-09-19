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
		items_out_of_view = SCROLL_CONTAINER.scroll_vertical / 40
	else:
		items_out_of_view = (SCROLL_CONTAINER_CONTENT.size.y - SCROLL_CONTAINER.size.y - SCROLL_CONTAINER.scroll_vertical) / 40

	if items_out_of_view > 1:
		%Text.text = "%d more to-dos %s" % [items_out_of_view, "above" if mode == Modes.UP else "below"]
	else:
		%Text.text = "%d more to-do %s" % [items_out_of_view, "above" if mode == Modes.UP else "below"]

	self.visible = (items_out_of_view > 0)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		SCROLL_CONTAINER.scroll_vertical -= 40 if mode == Modes.UP else -40
