class_name result_screen extends Control

@onready var title: Label = $Box/Content/Title
@onready var play_again: Button = $Box/Content/PlayAgain

func _ready() -> void:
	hide()
	play_again.pressed.connect(on_play_again_pressed)

func show_result(player_won: bool) -> void:
	title.text = "Victory!" if player_won else "Defeat..."
	show()
	play_again.grab_focus()

func on_play_again_pressed() -> void:
	get_tree().reload_current_scene()
