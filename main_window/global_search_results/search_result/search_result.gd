extends PanelContainer

var date : Date
var line_number : int


func fill_in(key, value, id) -> void:
	date = Date.from_string(key)
	%Text.text = value
	line_number = id

func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	%JumpTo.pressed.connect(_on_jump_to_pressed)


func _on_jump_to_pressed() -> void:
	Settings.current_day = date
	EventBus.bookmark_jump_requested.emit(date, line_number)


func _on_mouse_entered() -> void:
	theme_type_variation = "SearchResult_Focused"


func _on_mouse_exited() -> void:
	theme_type_variation = "SearchResult"
