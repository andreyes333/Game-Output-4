extends Control

enum States {
	OPTIONS,
	TARGETS,
}

var state: States = States.OPTIONS

@onready var _options: Menu = $Options
@onready var _player_options: SubMenu = $Options/PlayerOptions
@onready var _enemies_target: SubMenu = $Enemies
@onready var _player_target: SubMenu = $PlayerCharacters

func _ready() -> void:
	_player_options.button_focus(0)
	_enemies_target.button_pressed.connect(_on_enemies_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match state:
			States.OPTIONS:
				pass
			States.TARGETS:
				state = States.OPTIONS
				_player_options.button_focus()
		pass

func _on_player_options_button_focused(button: BaseButton) -> void:
	pass

func _on_player_options_button_pressed(button: BaseButton) -> void:
	match button.text:
		" Attack ":
			state = States.TARGETS
			_enemies_target.button_focus()
		" Magic ":
			state = States.TARGETS
			_enemies_target.button_focus()
		" Defend ":
			state = States.TARGETS
			_player_target.button_focus()
					

func _on_enemies_button_pressed(enemy_button: BaseButton) -> void:
	print("hit")
	enemy_button.heal_hurt(-1)
