extends VBoxContainer


var date : Date:
	set(value):
		if value:
			date = value

			%Date.text = date.format("MMM DD, YYYY") + ":"


func _ready() -> void:
	_setup_initial_state()
	_connect_signals()



func _setup_initial_state() -> void:
	%ExtraPadding.hide()


func _connect_signals() -> void:
	%FoldToggle.toggled.connect(_on_fold_toggle_toggled)
	%FoldToggle.mouse_entered.connect(_on_fold_toggle_mouse_entered)
	%FoldToggle.mouse_exited.connect(_on_fold_toggle_mouse_exited)


func _on_fold_toggle_toggled(toggled_on : bool) -> void:
	$Results.visible = not toggled_on

	if toggled_on:
		%ExtraPadding.show()
		%ItemCount.text = "(%d)" % $Results.get_child_count()
		%FoldToggle/Tooltip.text = "Unfold Group"
	else:
		%ExtraPadding.hide()
		%ItemCount.text = ""
		%FoldToggle/Tooltip.text = "Fold Group"


func _on_fold_toggle_mouse_entered() -> void:
	%FoldToggle.theme_type_variation = "ToDoItem_Focused"


func _on_fold_toggle_mouse_exited() -> void:
	%FoldToggle.theme_type_variation = "FlatButton"


func add_result(node : Node) -> void:
	$Results.add_child(node)


func contains_results() -> bool:
	return $Results.get_child_count() > 0
