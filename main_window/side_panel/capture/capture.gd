extends VBoxContainer


func _ready() -> void:
	%ScrollableTodoList.store_path = Settings.store_path.path_join("capture.txt")
