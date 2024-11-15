extends MarginContainer

@export_range(0, 100, 1, "suffix:px") var H_PADDING := 6
@export_range(0, 100, 1, "suffix:px") var V_PADDING := 6

@onready var v_scroll_bar : VScrollBar = get_parent().get_v_scroll_bar()
@onready var h_scroll_bar : HScrollBar = get_parent().get_h_scroll_bar()


func _ready() -> void:
	v_scroll_bar.visibility_changed.connect(_on_v_scroll_bar_visibility_changed)
	h_scroll_bar.visibility_changed.connect(_on_h_scroll_bar_visibility_changed)


func _on_v_scroll_bar_visibility_changed() -> void:
	if v_scroll_bar.visible:
		self.add_theme_constant_override("margin_right", H_PADDING)
	else:
		self.remove_theme_constant_override("margin_right")


func _on_h_scroll_bar_visibility_changed() -> void:
	if h_scroll_bar.visible:
		self.add_theme_constant_override("margin_bottom", V_PADDING)
	else:
		self.remove_theme_constant_override("margin_bottom")
