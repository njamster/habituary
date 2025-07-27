extends PanelContainer

@export var text := "":
	set(value):
		text = value
		$Label.text = text


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		fade_out_and_close(0.3)


func fade_out_and_close(duration := 2.0) -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	queue_free()
