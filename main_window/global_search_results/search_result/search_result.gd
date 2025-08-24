extends PanelContainer

var date : Date
var line_number : int


func fill_in(key, state, value, id) -> void:
	date = Date.from_string(key)
	_update_state_icon(state)
	%Text.text = value
	line_number = id


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	%JumpTo.pressed.connect(_on_jump_to_pressed)


func _update_state_icon(state : String) -> void:
	match state:
		"[x]":
			%State.texture = preload("res://main_window/list_view/day_panel/scrollable_todo_list/todo_list/todo_item/images/done.svg")
			%State.modulate = Color("#A3BE8C")
		"[-]":
			%State.texture = preload("res://main_window/list_view/day_panel/scrollable_todo_list/todo_list/todo_item/images/failed.svg")
			%State.modulate = Color("#D08770")
		_:
			%State.texture = preload("res://main_window/list_view/day_panel/scrollable_todo_list/todo_list/todo_item/images/to_do.svg")
			%State.modulate = Color("#FFFFFF")


func _on_jump_to_pressed() -> void:
	Settings.current_day = date
	EventBus.bookmark_jump_requested.emit(date, line_number)


func _on_mouse_entered() -> void:
	theme_type_variation = "SearchResult_Focused"


func _on_mouse_exited() -> void:
	theme_type_variation = "SearchResult"
