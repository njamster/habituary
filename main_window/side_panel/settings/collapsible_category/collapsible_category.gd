@tool
extends VBoxContainer


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	$Heading.toggled.connect(_on_toggled)

	$Content.visibility_changed.connect(_on_content_visibility_changed)


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$Content.hide()
	else:
		$Content.show()


func _on_content_visibility_changed() -> void:
	if $Content.visible:
		$Heading.set_pressed_no_signal(false)
		$Heading.icon = preload("images/unfolded.svg")
	else:
		$Heading.set_pressed_no_signal(true)
		$Heading.icon = preload("images/folded.svg")
