extends RefCounted
class_name ToDoListData


var to_dos: Array[ToDoData]


func add(to_do: ToDoData) -> void:
	to_dos.append(to_do)


func is_empty() -> bool:
	return to_dos.is_empty()
