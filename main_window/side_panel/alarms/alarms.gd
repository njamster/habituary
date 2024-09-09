extends VBoxContainer

var FILE_PATH := Settings.store_path.path_join("alarms.txt")


func _ready() -> void:
	if FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		while file.get_position() < file.get_length():
			_add_alarm(file.get_line())
		file.close()

	EventBus.alarm_added.connect(_on_alarm_added)
	EventBus.alarm_removed.connect(_on_alarm_removed)

	$List.child_entered_tree.connect(func(_node): $None.hide())
	$List.child_exiting_tree.connect(func(_node):
		$None.visible = ($List.get_child_count() == 1)
	)


func _add_alarm(line : String) -> void:
	var alarm := Label.new()
	alarm.text = line
	$List.add_child(alarm)


func _on_alarm_added(to_do : Control) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date = to_do.get_node("../../../../..").date.format(Settings.date_format_save)
	var alarm_text = "[%s] %s" % [date, to_do.text]

	for alarm in $List.get_children():
		if alarm.text == alarm_text:
			return

	_add_alarm(alarm_text)
	# TODO: save new state to disk


func _on_alarm_removed(to_do : Control) -> void:
	# FIXME: avoid using a relative path that involves parent nodes
	var date = to_do.get_node("../../../../..").date.format(Settings.date_format_save)
	var alarm_text = "[%s] %s" % [date, to_do.text]

	for alarm in $List.get_children():
		if alarm.text == alarm_text:
			alarm.queue_free()
			# TODO: save new state to disk
			return
