extends RefCounted
class_name ToDoListData


signal changed(reason: String)

signal to_do_added(to_do: ToDoData, at_index: int, auto_edit: bool)
signal to_do_removed(at_index: int)


var to_dos: Array[ToDoData]

var indentation_level := 0:
	set(value):
		indentation_level = value
		for to_do in to_dos:
			to_do.indentation_level = value

var parent: RefCounted


func _init(p_parent: RefCounted = null) -> void:
	parent = p_parent


func add(to_do: ToDoData, at_index := -1, auto_edit := false, emit := true) -> void:
	if at_index >= 0 and at_index <= to_dos.size():
		to_dos.insert(at_index, to_do)
	else:
		to_dos.append(to_do)
		at_index = -1
	to_do.parent = self
	to_do.indentation_level = indentation_level
	to_do.sub_items.changed.connect(to_do.changed.emit)
	to_do.indent_requested.connect(indent.bind(to_do))
	to_do.delete_requested.connect(remove.bind(to_do))
	to_do.changed.connect(changed.emit)
	if emit:
		changed.emit("to-do added")
		to_do_added.emit(to_do, at_index, auto_edit)


func remove(to_do: ToDoData, emit := true) -> void:
	var at_index = to_dos.find(to_do)
	to_dos.erase(to_do)
	to_do.parent = null
	to_do.indentation_level = -1
	to_do.sub_items.changed.disconnect(to_do.changed.emit)
	to_do.indent_requested.disconnect(indent)
	to_do.delete_requested.disconnect(remove)
	to_do.changed.disconnect(changed.emit)
	if emit:
		changed.emit("to-do removed")
		to_do_removed.emit(at_index)


func move(to_do: ToDoData, to_position: int) -> void:
	var index := to_dos.find(to_do)

	if index == -1:
		return  # early

	to_dos.remove_at(index)
	to_dos.insert(to_position, to_do)

	changed.emit("to-do moved")


func indent(to_do: ToDoData) -> void:
	var index := to_dos.find(to_do)

	if index <= 0:
		return  # early

	remove(to_do, false)
	to_dos[index - 1].sub_items.add(to_do, -1, false, false)

	changed.emit("to-do indented")


func unindent(to_do: ToDoData) -> void:
	var index := to_dos.find(to_do)

	if index == -1:
		return  # early

	if indentation_level < 1:
		return  # early

	var parent_list: ToDoListData = parent.parent
	if parent_list:
		var at_position = parent_list.to_dos.find(parent)
		remove(to_do, false)
		parent_list.add(to_do, at_position + 1, false, false)

		changed.emit("to-do unindented")


func search(query: String) -> Array[ToDoData]:
	var results: Array[ToDoData] = []

	for to_do in to_dos:
		if to_do.text.contains(query):
			results.append(to_do)
			results += to_do.sub_items.search(query)

	return results


func is_empty() -> bool:
	return to_dos.is_empty()


func get_item_above(to_do: ToDoData) -> ToDoData:
	var index := to_dos.find(to_do)
	if index != -1:
			if index == 0:
				if parent is not FileData:
					# item is the first sub item of another item -> return that item
					return parent
			else:
				# item has at least one item before it...
				var item_above := to_dos[index - 1]
				# ... if that item has any sub items -> return the last of them
				while not item_above.sub_items.is_empty():
					item_above = item_above.sub_items.to_dos[-1]
				return item_above

	return null


func get_item_below(to_do: ToDoData) -> ToDoData:
	var index := to_dos.find(to_do)
	if index != -1:
		if index < to_dos.size() - 1:
			# item has at least one item after it -> return that
			return to_dos[index + 1]

		if parent is not FileData:
			var parent_list: ToDoListData = parent.parent
			if parent_list:
				# item is the final sub item of another item
				# -> return the item after that item (if there is any)
				return parent_list.get_item_below(parent)

	return null


func clear() -> void:
	to_dos.clear()
