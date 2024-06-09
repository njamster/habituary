extends Control

const TODO_ITEM := preload("res://day_panel/todo_item/todo_item.tscn")

var current_day : Date:
	set(value):
		current_day = value
		if is_inside_tree():
			DATE.text = current_day.format(Settings.date_format_show)
			for child in ITEMS.get_children():
				child.free()
			load_day(current_day)

@onready var DATE := %Date
@onready var ITEMS := %Items


func _ready() -> void:
	current_day = Date.new(Time.get_date_dict_from_system())
	SaveTimer.timeout.connect(save_current_day)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if not SaveTimer.is_stopped():
			SaveTimer.stop()
			save_current_day()
		get_tree().quit()


func save_current_day() -> void:
	var todo_list = ""
	for todo_item in ITEMS.get_children():
		if todo_item.done:
			todo_list += "- [x] "
		else:
			todo_list += "- [ ] "
		todo_list += todo_item.text + "\n"

	var file_name := current_day.format(Settings.date_format_save) + ".txt"
	if todo_list:
		var file := FileAccess.open(Settings.store_path + "/" + file_name, FileAccess.WRITE)
		file.store_string(todo_list)
	else:
		DirAccess.remove_absolute(Settings.store_path + "/" + file_name)


func load_day(day: Date) -> void:
	var file_name := day.format(Settings.date_format_save) + ".txt"
	var file := FileAccess.open(Settings.store_path + "/" + file_name, FileAccess.READ)
	if file:
		while file.get_position() < file.get_length():
			var todo_item := TODO_ITEM.instantiate()

			var next_line := file.get_line()
			if next_line.begins_with("- [ ] "):
				todo_item.text = next_line.lstrip("- [ ] ")
				todo_item.done = false
			elif next_line.begins_with("- [x] "):
				todo_item.text = next_line.lstrip("- [x] ")
				todo_item.done = true
			else:
				# TODO: print warning
				continue

			ITEMS.add_child(todo_item)

		# select first item in the list that is *not* done
		for item in ITEMS.get_children():
			if not item.done:
				item.grab_focus()
				break


func _unhandled_input(event: InputEvent) -> void:
	var focused_item = get_viewport().gui_get_focus_owner()

	if event.is_action_pressed("add_item_below", false, true) or event.is_action_pressed("add_item_above", false, true):
		var todo_item := TODO_ITEM.instantiate()
		if not focused_item:
			ITEMS.add_child(todo_item)
		else:
			focused_item.add_sibling(todo_item)
			if event.is_action_pressed("add_item_above", false, true):
				ITEMS.move_child(todo_item, max(focused_item.get_index(), 0))
		todo_item.edit()
	elif event.is_action_pressed("shift_item_up", false, true):
		if focused_item:
			ITEMS.move_child(focused_item, clamp(focused_item.get_index() - 1, 0, ITEMS.get_child_count()))
		SaveTimer.start()
	elif event.is_action_pressed("shift_item_down", false, true):
		if focused_item:
			ITEMS.move_child(focused_item, clamp(focused_item.get_index() + 1, 0, ITEMS.get_child_count()))
		SaveTimer.start()
	elif event.is_action_pressed("move_up", false, true):
		if focused_item:
			var previous_item := focused_item.find_valid_focus_neighbor(SIDE_TOP)
			if previous_item:
				previous_item.grab_focus()
	elif event.is_action_pressed("move_down", false, true):
		if focused_item:
			var next_item := focused_item.find_valid_focus_neighbor(SIDE_BOTTOM)
			if next_item:
				next_item.grab_focus()
	elif event.is_action_pressed("select_first_item", false, true):
		if ITEMS.get_child_count():
			ITEMS.get_child(0).grab_focus()
	elif event.is_action_pressed("select_last_item", false, true):
		if ITEMS.get_child_count():
			ITEMS.get_child(-1).grab_focus()
	elif event.is_action_pressed("previous_day", false, true):
		_on_prev_day_pressed()
	elif event.is_action_pressed("next_day", false, true):
		_on_next_day_pressed()
	elif event.is_action_pressed("replace_item_text", false, true):
		if focused_item:
			focused_item.edit()
	elif event.is_action_pressed("prepend_item_text", false, true):
		if focused_item:
			focused_item.edit(-1)
	elif event.is_action_pressed("append_item_text", false, true):
		if focused_item:
			focused_item.edit(+1)
	elif event.is_action_pressed("delete_item", false, true):
		if not focused_item:
			return
		elif focused_item.get_index() == 0:
			if ITEMS.get_child_count() > 1:
				ITEMS.get_child(1).grab_focus()
		else:
			ITEMS.get_child(focused_item.get_index() - 1).grab_focus()
		focused_item.queue_free()
		SaveTimer.start()


func _on_prev_day_pressed() -> void:
	if not SaveTimer.is_stopped():
		SaveTimer.stop()
		save_current_day()
	current_day = current_day.add_days(-1)


func _on_next_day_pressed() -> void:
	if not SaveTimer.is_stopped():
		SaveTimer.stop()
		save_current_day()
	current_day = current_day.add_days(1)
