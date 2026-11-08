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

@export var player_party: Array[actor_data]
@export var enemy_party: Array[actor_data]

func _ready() -> void:
	_player_options.button_focus(0)
	_enemies_target.button_pressed.connect(_on_enemies_button_pressed)
	_setup_party(_player_target, player_party)
	_setup_party(_enemies_target, enemy_party)

func _setup_party(container: Node, party: Array[actor_data]) -> void:
	var actors: Array = container.get_children()
	for i in actors.size():
		if i < party.size() and party[i]:
			actors[i].setup(party[i])
		else:
			actors[i].queue_free()

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
