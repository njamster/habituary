extends Control

const TODO_ITEM := preload("res://day_panel/todo_item/todo_item.tscn")

@onready var DATE := %Date
@onready var ITEMS := %Items


func _ready() -> void:
	var today = DateTime.new(Time.get_date_dict_from_system())
	DATE.text = today.format(Settings.date_format_show)

	var file_name := today.format(Settings.date_format_save) + ".txt"
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
	elif event.is_action_pressed("edit_replace_item", false, true):
		if focused_item:
			focused_item.edit(true)
	elif event.is_action_pressed("edit_append_item", false, true):
		if focused_item:
			focused_item.edit()
	elif event.is_action_pressed("delete_item", false, true):
		if not focused_item:
			return
		elif focused_item.get_index() == 0:
			if ITEMS.get_child_count() > 1:
				ITEMS.get_child(1).grab_focus()
		else:
			ITEMS.get_child(focused_item.get_index() - 1).grab_focus()
		focused_item.queue_free()
