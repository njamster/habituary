extends RefCounted
class_name ToDoListData


signal changed(reason: String)
signal to_do_added(to_do: ToDoData, at_index: int)


var to_dos: Array[ToDoData]

var indentation_level := 0
var parent: ToDoData


func _init(p_parent: ToDoData = null) -> void:
	parent = p_parent


func add(to_do: ToDoData, at_index := -1, emit := true) -> void:
	if at_index >= 0 and at_index <= to_dos.size():
		to_dos.insert(at_index, to_do)
	else:
		to_dos.append(to_do)
		at_index = -1
	to_do.parent = self
	to_do.indentation_level = indentation_level
	to_do.sub_items.indentation_level = indentation_level + 1
	to_do.sub_items.changed.connect(to_do.changed.emit)
	to_do.indent_requested.connect(indent.bind(to_do))
	to_do.delete_requested.connect(remove.bind(to_do))
	to_do.changed.connect(changed.emit)
	if emit:
		changed.emit("to-do added")
		to_do_added.emit(to_do, at_index)


func remove(to_do: ToDoData, emit := true) -> void:
	to_dos.erase(to_do)
	to_do.parent = null
	to_do.indentation_level = -1
	to_do.sub_items.indentation_level = -1
	to_do.sub_items.changed.disconnect(to_do.changed.emit)
	to_do.indent_requested.disconnect(indent)
	to_do.delete_requested.disconnect(remove)
	to_do.changed.disconnect(changed.emit)
	if emit:
		changed.emit("to-do removed")


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
	to_dos[index - 1].sub_items.add(to_do, -1, false)

	changed.emit("to-do indented")


func unindent(to_do: ToDoData) -> void:
	var index := to_dos.find(to_do)

	if index == -1:
		return  # early

	var parent_list := parent.parent
	if parent_list:
		var at_position = parent_list.to_dos.find(parent)
		remove(to_do, false)
		parent_list.add(to_do, at_position + 1, false)

		changed.emit("to-do unindented")


func is_empty() -> bool:
	return to_dos.is_empty()


func clear() -> void:
	to_dos.clear()
