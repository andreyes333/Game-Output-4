extends Control

signal battle_ended(player_won: bool)

enum States {
	OPTIONS,
	TARGETS,
	RESOLVING,
	OVER,
}

const MESSAGE_DELAY := 0.6

var state: States = States.OPTIONS

@onready var _options: Menu = $Options
@onready var _player_options: SubMenu = $Options/PlayerOptions
@onready var _enemies_target: SubMenu = $Enemies
@onready var _player_target: SubMenu = $PlayerCharacters
@onready var _cursor: Control = $MenuCursor

@export var player_party: Array[actor_data]
@export var enemy_party: Array[actor_data]

var _choosers: Array[battle_actor] = []
var _chooser_index: int = 0
var _choices: Array[battle_action] = []
var _pending_move: move_data

func _ready() -> void:
	_enemies_target.button_pressed.connect(_on_target_pressed)
	_player_target.button_pressed.connect(_on_target_pressed)
	_setup_party(_player_target, player_party)
	_setup_party(_enemies_target, enemy_party)
	await get_tree().process_frame
	_start_turn()

func _setup_party(container: Node, party: Array[actor_data]) -> void:
	var actors: Array = container.get_children()
	for i in actors.size():
		if i < party.size() and party[i]:
			actors[i].setup(party[i])
		else:
			actors[i].queue_free()

func _living(container: Node) -> Array[battle_actor]:
	var result: Array[battle_actor] = []
	for child in container.get_children():
		if child is battle_actor and child.is_alive() and not child.is_queued_for_deletion():
			result.append(child)
	return result

func _can_act(actor) -> bool:
	return is_instance_valid(actor) and actor.is_alive()

func _start_turn() -> void:
	for actor in _living(_player_target) + _living(_enemies_target):
		actor.guarding = false
	_choosers = _living(_player_target)
	_chooser_index = 0
	_choices.clear()
	_prompt_chooser()

func _prompt_chooser() -> void:
	if _chooser_index >= _choosers.size():
		_resolve_turn()
		return
	var actor := _choosers[_chooser_index]
	var moves := actor.data.moves
	var buttons := _player_options.get_buttons()
	for i in buttons.size():
		var button: Button = buttons[i]
		button.visible = i < moves.size()
		if button.visible:
			button.text = " %s " % moves[i].name
	state = States.OPTIONS
	_options.show()
	_log("What will %s do?" % actor.data.name)
	_player_options.button_focus(0)

func _on_player_options_button_focused(button: BaseButton) -> void:
	pass

func _on_player_options_button_pressed(button: BaseButton) -> void:
	if state != States.OPTIONS:
		return
	var actor := _choosers[_chooser_index]
	var move: move_data = actor.data.moves[button.get_index()]
	if move.target == move_data.Target.ONE_ENEMY:
		_pending_move = move
		state = States.TARGETS
		_focus_party(_enemies_target)
	elif move.target == move_data.Target.ONE_ALLY:
		_pending_move = move
		state = States.TARGETS
		_focus_party(_player_target)
	elif move.target == move_data.Target.SELF:
		_choose(battle_action.new(actor, move, actor))
	else:
		_choose(battle_action.new(actor, move, null))

func _focus_party(party: SubMenu) -> void:
	var count := party.get_buttons().size()
	party.button_focus(clampi(party.index, 0, count - 1))

func _on_target_pressed(button: BaseButton) -> void:
	if state != States.TARGETS:
		return
	var target := button as battle_actor
	if target == null:
		return
	var actor := _choosers[_chooser_index]
	var wants_foe := _pending_move.target == move_data.Target.ONE_ENEMY
	var is_foe := target.is_player != actor.is_player
	if wants_foe != is_foe:
		return
	_choose(battle_action.new(actor, _pending_move, target))

func _choose(action: battle_action) -> void:
	_choices.append(action)
	_chooser_index += 1
	_prompt_chooser()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if state == States.OPTIONS and _chooser_index > 0:
		_chooser_index -= 1
		_choices.pop_back()
		_prompt_chooser()
	elif state == States.TARGETS:
		state = States.OPTIONS
		_player_options.button_focus()

func _lock_menus() -> void:
	get_viewport().gui_release_focus()
	for menu in [_player_options, _enemies_target, _player_target]:
		menu.button_enable_focus(false)
	_options.hide()
	_cursor.hide()

func _resolve_turn() -> void:
	state = States.RESOLVING
	_lock_menus()
	var enemies := _living(_enemies_target)
	var players := _living(_player_target)
	for enemy in enemies:
		var action := enemy_ai.choose(enemy, enemies, players)
		if action:
			_choices.append(action)
	_choices.sort_custom(func(a: battle_action, b: battle_action) -> bool: return battle_action.goes_before(a, b))
	for action in _choices:
		if not _can_act(action.actor):
			continue
		await _perform(action)
		if _check_battle_over():
			return
	_start_turn()

func _perform(action: battle_action) -> void:
	var actor := action.actor
	var move := action.move
	var foes := _living(_enemies_target if actor.is_player else _player_target)
	_log("%s used %s!" % [actor.data.name, move.name])
	await _pause()
	if move.kind == move_data.Kind.DAMAGE:
		var targets: Array[battle_actor] = []
		if move.target == move_data.Target.ALL_ENEMIES:
			targets = foes
		elif _can_act(action.target):
			targets.append(action.target)
		elif not foes.is_empty():
			targets.append(foes[0])
		for target in targets:
			await _hit(actor, target, move)
	elif move.kind == move_data.Kind.HEAL:
		if not _can_act(action.target):
			_log("But it failed!")
			await _pause()
			return
		var target: battle_actor = action.target
		var before := target.hp
		await target.heal_hurt(move.power)
		_log("%s recovered %d HP." % [target.data.name, target.hp - before])
		await _pause()
	elif move.kind == move_data.Kind.DEFEND:
		actor.guarding = true
		_log("%s is guarding." % actor.data.name)
		await _pause()
	else:
		_log("But nothing happened.")
		await _pause()

func _hit(actor: battle_actor, target: battle_actor, move: move_data) -> void:
	var target_name := target.data.name
	var result := combat.roll_damage(actor, target, move)
	if result.crit:
		_log("A critical hit!")
	await target.heal_hurt(-result.amount)
	var fainted := not target.is_alive()
	_log("%s took %d damage." % [target_name, result.amount])
	await _pause()
	if fainted:
		_log("%s fainted!" % target_name)
		await _pause()

func _check_battle_over() -> bool:
	if _living(_enemies_target).is_empty():
		_finish(true)
		return true
	if _living(_player_target).is_empty():
		_finish(false)
		return true
	return false

func _finish(player_won: bool) -> void:
	state = States.OVER
	_log("You win!" if player_won else "Your party was defeated...")
	battle_ended.emit(player_won)

func _log(text: String) -> void:
	print(text)

func _pause() -> void:
	await get_tree().create_timer(MESSAGE_DELAY).timeout
