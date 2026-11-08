class_name battle_log extends Label

const CHARACTERS_PER_SECOND = 45.0

var tween: Tween

func set_message(message: String) -> void:
	stop_tween()
	text = message
	visible_ratio = 1.0

func show_message(message: String) -> void:
	stop_tween()
	text = message
	visible_ratio = 0.0
	tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, message.length() / CHARACTERS_PER_SECOND)
	await tween.finished

func stop_tween() -> void:
	if tween and tween.is_valid():
		tween.kill()
