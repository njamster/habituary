extends MarginContainer

const INITIAL_DELAY := 0.9 # seconds
const REPEAT_DELAY := 0.5 # seconds

@export var day_offset := 0

@onready var timer := Timer.new()


func _ready() -> void:
	add_child(timer)

	timer.timeout.connect(_on_timer_timeout)


func _on_mouse_entered() -> void:
	timer.start(INITIAL_DELAY)


func _on_mouse_exited() -> void:
	timer.stop()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		timer.stop()


func _on_timer_timeout() -> void:
	Settings.current_day = Settings.current_day.add_days(day_offset)

	timer.start(REPEAT_DELAY)
