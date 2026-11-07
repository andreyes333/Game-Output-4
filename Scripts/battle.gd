extends Control

enum States {
	OPTIONS,
	TARGETS,
}

var state: States = States.OPTIONS

@onready var _options: Menu = $Options
@onready var _player_options: SubMenu = $Options/PlayerOptions
@onready var _enemies_options: SubMenu = $Enemies

func _ready() -> void:
	_player_options.button_focus(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match state:
			States.OPTIONS:
				pass
			States.TARGETS:
				state == States.OPTIONS
				_player_options.button_focus()
		pass

func _on_player_options_button_focused(button: BaseButton) -> void:
	pass

func _on_player_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		" Attack ":
			state = States.TARGETS
			_enemies_options.button_focus()
