extends PanelContainer

var date : Date
var line_number : int


func fill_in(key, state, value, id) -> void:
	date = Date.from_string(key)
	_update_state_icon(state)
	%Text.text = value
	line_number = id


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


func _setup_initial_state() -> void:
	_adjust_text_width()


func _connect_signals() -> void:
	#region Local Signals
	item_rect_changed.connect(_adjust_text_width)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	%JumpTo.pressed.connect(_on_jump_to_pressed)
	#endregion


func _update_state_icon(state : String) -> void:
	match state:
		"[x]":
			%State.texture = preload("images/done.svg")
			%State.modulate = Color("#A3BE8C")
		"[-]":
			%State.texture = preload("images/failed.svg")
			%State.modulate = Color("#D08770")
		_:
			%State.texture = preload("images/to_do.svg")
			%State.modulate = Color("#FFFFFF")


func _on_jump_to_pressed() -> void:
	Settings.current_day = date
	EventBus.bookmark_jump_requested.emit(date, line_number)


func _on_mouse_entered() -> void:
	theme_type_variation = "SearchResult_Focused"


func _on_mouse_exited() -> void:
	theme_type_variation = "SearchResult"


func _adjust_text_width() -> void:
	var text_width = get_theme_default_font().get_string_size(
		%Text.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		get_theme_default_font_size()
	).x
	var max_width: int = (
		$HBox.size.x
		- %State.texture.get_width()
		- 1  # minimum RichTextLabel width
		- get_theme_constant("separation", $HBox.theme_type_variation)
		  * ($HBox.get_child_count() - 1)
		- %JumpTo.icon.get_width()
	)
	%Text.size_flags_stretch_ratio = text_width / max_width
	%ExtraPadding.size_flags_stretch_ratio = 1.0 - text_width / max_width
