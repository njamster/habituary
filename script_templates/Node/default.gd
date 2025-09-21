# meta-description: Base template for any Node
# meta-default: true
extends _BASE_


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_initial_state()
	_connect_signals()


## Called in [method ready] to make modifications to the node's initial state
## [i]before[/i] any (global or local) signals will be connected.
func _setup_initial_state() -> void:
	pass  # TODO


## Called in [method ready] to connect signals to their callbacks. Prefer this
## over connecting signals via the editor UI! Separate global signals (defined
## in autoloads) from local ones (in the node or its children).
func _connect_signals() -> void:
	#region Global Signals
	pass  # TODO
	#endregion

	#region Local Signals
	pass  # TODO
	#endregion
