extends RefCounted
class_name ToDoListData


signal changed


var to_dos: Array[ToDoData]

var indentation_level: int


func _init(p_indentation_level := 0) -> void:
	indentation_level = p_indentation_level


func add(to_do: ToDoData) -> void:
	to_dos.append(to_do)
	to_do.parent_list = self
	to_do.changed.connect(changed.emit)
	changed.emit()


func remove(to_do: ToDoData) -> void:
	to_dos.erase(to_do)
	to_do.parent_list = null
	to_do.changed.disconnect(changed.emit)
	changed.emit()


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
