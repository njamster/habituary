class_name DragHoverTrigger
extends Timer


## Emitted when the mouse cursor remains long enough over the parent's visible
## area while dragging something.
signal triggered

## When the mouse cursor remains this long over the parent's visible area while
## dragging something, [signal triggered] is emitted for the first time.
@export_range(0, 3, 0.1, "or_greater", "suffix:seconds") var initial_delay := 0.9
## If the mouse cursor remains this much longer over the parent's visible area
## after the [param initial_delay], [signal triggered] is emitted again.
@export_range(0, 3, 0.1, "or_greater", "suffix:seconds") var echo_delay := 0.5

@onready var host := get_parent()


func _ready() -> void:
	timeout.connect(_on_timeout)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_BEGIN:
			host.mouse_entered.connect(_on_mouse_entered)
			host.mouse_exited.connect(_on_mouse_exited)
		NOTIFICATION_DRAG_END:
			stop()
			if host.mouse_exited.is_connected(_on_mouse_exited):
				host.mouse_exited.disconnect(_on_mouse_exited)
			if host.mouse_entered.is_connected(_on_mouse_entered):
				host.mouse_entered.disconnect(_on_mouse_entered)


func _on_mouse_entered() -> void:
	start(initial_delay)


func _on_mouse_exited() -> void:
	stop()


func _on_timeout() -> void:
	triggered.emit()
	start(echo_delay)
