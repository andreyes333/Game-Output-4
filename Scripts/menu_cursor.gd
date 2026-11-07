extends TextureRect

var offset: Vector2 = Vector2(-16, -4)

var target: Node = null

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_viewport_gui_focus_changed)
	set_process(false)

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	global_position = target.global_position + offset

func _on_viewport_gui_focus_changed(node: Control) -> void:
	if node is BaseButton:
		target = node
		show()
		set_process(true)
	else:
		hide()
		set_process(false)
