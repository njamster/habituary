extends CanvasLayer


func _ready() -> void:
	hide()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_BEGIN:
			if get_viewport().gui_get_drag_data() is Array:
				show()
		NOTIFICATION_DRAG_END:
			hide()
