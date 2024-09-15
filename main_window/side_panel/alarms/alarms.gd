extends VBoxContainer

var FILE_PATH := Settings.store_path.path_join("alarms.txt")


func _ready() -> void:
	#if FileAccess.file_exists(FILE_PATH):
		#var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		#while file.get_position() < file.get_length():
			#_add_alarm(file.get_line())
		#file.close()

	EventBus.alarm_added.connect(_on_alarm_added)
	EventBus.alarm_text_changed.connect(_on_alarm_text_changed)
	EventBus.alarm_removed.connect(_on_alarm_removed)

	%List.child_entered_tree.connect(func(_node): $None.hide())
	%List.child_exiting_tree.connect(func(_node):
		$None.visible = (%List.get_child_count() == 1)
	)


func _add_alarm(date : Date, todo_text : String) -> void:
	var alarm := preload("alarm/alarm.tscn").instantiate()
	alarm.date = date
	alarm.text = todo_text
	%List.add_child(alarm)

	for i in %List.get_child_count():
		var child = %List.get_child(i)
		if child.date.day_difference_to(date) > 0:
			%List.move_child(alarm, i)
			return


func _on_alarm_added(to_do : Control) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date := Date.new(to_do.get_node("../../../../..").date.as_dict())

	for alarm in %List.get_children():
		if alarm.text == to_do.text and alarm.date.day_difference_to(date) == 0:
			return

	_add_alarm(date, to_do.text)
	# TODO: save new state to disk


func _on_alarm_text_changed(to_do : Control, old_text : String) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date := Date.new(to_do.get_node("../../../../..").date.as_dict())

	for child in %List.get_children():
		if child.text == old_text and child.date.day_difference_to(date) == 0:
			child.text = to_do.text
			return


func _on_alarm_removed(to_do : Control) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date := Date.new(to_do.get_node("../../../../..").date.as_dict())

	for alarm in %List.get_children():
		if alarm.text == to_do.text and alarm.date.day_difference_to(date) == 0:
			alarm.queue_free()
			# TODO: save new state to disk
			return
