extends Timer


func _ready() -> void:
	wait_time = Settings.save_delay
	one_shot = true
