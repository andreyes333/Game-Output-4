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

@onready var battle_enemy_1: enemy_target = $Enemies/BattleEnemy
@onready var battle_enemy_2: enemy_target = $Enemies/BattleEnemy2
@onready var battle_enemy_3: enemy_target = $Enemies/BattleEnemy3
@export var enemy_data1: enemy_data
@export var enemy_data2: enemy_data
@export var enemy_data3: enemy_data

func _ready() -> void:
	_player_options.button_focus(0)
	_enemies_target.button_pressed.connect(_on_enemies_button_pressed)

	if enemy_data1:
		battle_enemy_1.setup_enemy(enemy_data1)
	if enemy_data2:
		battle_enemy_2.setup_enemy(enemy_data2)
	if enemy_data3:
		battle_enemy_3.setup_enemy(enemy_data3)

func add_event(actor: Object, type: int, target: Object) -> void:
	pass
	
func run_event() -> void:
	pass

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
