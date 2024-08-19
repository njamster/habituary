extends CanvasLayer


func _ready() -> void:
	deactivate()


func activate() -> void:
	show()
	set_process(true)


func deactivate() -> void:
	set_process(false)
	hide()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_BEGIN:
			if get_viewport().gui_get_drag_data() is Array:
				activate()
		NOTIFICATION_DRAG_END:
			deactivate()


func _process(_delta: float) -> void:
	var window_size = get_window().size.x
	$LeftBorder.visible = (get_parent().get_global_mouse_position().x < 0.1 * window_size)
	$RightBorder.visible = (get_parent().get_global_mouse_position().x > 0.9 * window_size)
