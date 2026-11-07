extends Node
const PRINT_CURRENT_FOCUS: bool = false

func _unhandled_key_input(event: InputEvent) -> void:
	var inputeventkey: InputEventKey = event
	if event.is_pressed():
		var key: int = inputeventkey.keycode
		match key:
			KEY_R:
				get_tree().reload_current_scene()
			KEY_Q:
				get_tree().quit()
			KEY_F:
				var current_mode = DisplayServer.window_get_mode()
				if current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
