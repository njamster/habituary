extends RefCounted
class_name ToDoListData


signal changed(reason: String)


var to_dos: Array[ToDoData]

var indentation_level: int


func _init(p_indentation_level := 0) -> void:
	indentation_level = p_indentation_level


func add(to_do: ToDoData, at_index := -1) -> void:
	if at_index >= 0 and at_index <= to_dos.size():
		to_dos.insert(at_index, to_do)
	else:
		to_dos.append(to_do)
	to_do.indentation_level = indentation_level
	to_do.indent_requested.connect(indent.bind(to_do))
	to_do.delete_requested.connect(remove.bind(to_do))
	to_do.changed.connect(changed.emit)
	changed.emit("to-do added")


func remove(to_do: ToDoData) -> void:
	to_dos.erase(to_do)
	to_do.indentation_level = -1
	to_do.indent_requested.disconnect(indent)
	to_do.delete_requested.disconnect(remove)
	to_do.changed.disconnect(changed.emit)
	changed.emit("to-do removed")


func indent(to_do: ToDoData) -> void:
	var index := to_dos.find(to_do)

	if index == 0:
		return  # early

	remove(to_do)
	to_dos[index - 1].sub_items.add(to_do)


func is_empty() -> bool:
	return to_dos.is_empty()


func clear() -> void:
	to_dos.clear()
