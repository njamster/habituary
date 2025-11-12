extends TextureRect


enum Modes {UP, DOWN}
@export var mode := Modes.UP:
	set(value):
		mode = value

		if mode == Modes.UP:
			texture = null
		else:
			texture = preload("images/line.svg")

@onready var SCROLL_CONTAINER := get_parent().get_node("ScrollContainer")
@onready var SCROLL_CONTAINER_CONTENT := SCROLL_CONTAINER.get_child(0)

var items_out_of_view := 0


func _ready() -> void:
	_connect_signals()
	self.hide()


func _connect_signals() -> void:
	#region Global Signals
	Settings.search_query_changed.connect(_on_search_query_changed)
	#endregion

	#region Parent Signals
	SCROLL_CONTAINER.resized.connect.call_deferred(_update_button)
	SCROLL_CONTAINER_CONTENT.resized.connect.call_deferred(_update_button)

	SCROLL_CONTAINER.scrolled.connect.call_deferred(_update_button)
	SCROLL_CONTAINER.auto_scrolled.connect.call_deferred(_update_button)

	_update_button.call_deferred()
	#endregion

	#region Local Signals
	gui_input.connect(_on_gui_input)

	$DragHoverTrigger.triggered.connect(_on_drag_hover_trigger_triggered)
	#endregion


func _update_button() -> void:
	if not is_visible_in_tree():
		return  # early

	if SCROLL_CONTAINER_CONTENT.get_node("%Items").get_child_count() == 0:
		self.hide()
		_on_search_query_changed()
		return  # early

	items_out_of_view = 0

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

	_on_search_query_changed()


func _on_scroll_button_pressed() -> void:
	if mode == Modes.UP:
		SCROLL_CONTAINER._scroll_one_item_up()
	else:
		SCROLL_CONTAINER._scroll_one_item_down()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_released("left_mouse_button"):
		_on_scroll_button_pressed()


func _on_drag_hover_trigger_triggered() -> void:
	_on_scroll_button_pressed()


func _on_search_query_changed() -> void:
	if not Settings.search_query:
		if mode == Modes.UP:
			%Text.text = "%d more to-dos above" % items_out_of_view
		else:
			%Text.text = "%d more to-dos below" % items_out_of_view
		%Text.theme_type_variation = "ScrollButtonText"
		%Text.modulate.a = 1.0
	else:
		var matches_outside_view := 0

		for i in range(items_out_of_view):
			var todo
			if mode == Modes.UP:
				todo = SCROLL_CONTAINER_CONTENT.get_node("%Items").get_child(i)
			else:
				todo = SCROLL_CONTAINER_CONTENT.get_node("%Items").get_child(-i - 1)
			if todo.text.contains(Settings.search_query):
				matches_outside_view += 1

		if matches_outside_view:
			if matches_outside_view == 1:
				%Text.text = "%d match" % matches_outside_view
			else:
				%Text.text = "%d matches" % matches_outside_view
			if mode == Modes.UP:
				%Text.text += " above"
			else:
				%Text.text += " below"
			%Text.theme_type_variation = "ScrollButtonText_SearchMatch"
			%Text.modulate.a = 1.0
		else:
			if mode == Modes.UP:
				%Text.text = "%d more to-dos above" % items_out_of_view
			else:
				%Text.text = "%d more to-dos below" % items_out_of_view
			%Text.theme_type_variation = "ScrollButtonText"
			%Text.modulate.a = 0.1
