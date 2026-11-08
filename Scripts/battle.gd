extends Control

signal battle_ended(player_won: bool)

enum States {
	OPTIONS,
	TARGETS,
	RESOLVING,
	OVER,
}

const MESSAGE_DELAY = 0.6
const ACTIVE_NAME_COLOR = Color(0.15, 0.55, 0.15)
const FAINTED_ALPHA = 0.4

var state: States = States.OPTIONS

@onready var options: Menu = $Options
@onready var player_options: SubMenu = $Options/PlayerOptions
@onready var enemies_target: SubMenu = $Enemies
@onready var player_target: SubMenu = $PlayerCharacters
@onready var cursor: Control = $MenuCursor
@onready var message_box: battle_log = $LogBox/BattleLog
@onready var results: result_screen = $ResultScreen
@onready var enemy_labels: Array = $GUIMargin/BottomMenu/Enemies/MarginContainer/VBoxContainer.get_children()
@onready var player_rows: Array = $GUIMargin/BottomMenu/Players/MarginContainer/VBoxContainer.get_children()

@export var player_party: Array[actor_data]
@export var enemy_party: Array[actor_data]

var choosers: Array[battle_actor] = []
var chooser_index: int = 0
var choices: Array[battle_action] = []
var pending_move: move_data
var player_rows_by_actor = {}

func _ready() -> void:
	enemies_target.button_pressed.connect(on_target_pressed)
	player_target.button_pressed.connect(on_target_pressed)
	setup_party(player_target, player_party)
	setup_party(enemies_target, enemy_party)
	await get_tree().process_frame
	bind_status_panel()
	start_turn()

func setup_party(container: Node, party: Array[actor_data]) -> void:
	var actors: Array = container.get_children()
	for i in actors.size():
		if i < party.size() and party[i]:
			actors[i].setup(party[i])
		else:
			actors[i].queue_free()

func bind_status_panel() -> void:
	var players: Array[battle_actor] = living(player_target)
	for i in player_rows.size():
		var row = player_rows[i]
		if i >= players.size():
			row.hide()
			continue
		var actor: battle_actor = players[i]
		player_rows_by_actor[actor] = row
		row.get_node("Name").text = actor.data.name
		row.get_node("Health").init_health(actor.hp_max)
		actor.hp_changed.connect(update_player_row)
		update_player_row(actor)
	var enemies: Array[battle_actor] = living(enemies_target)
	for i in enemy_labels.size():
		var label: Label = enemy_labels[i]
		if i >= enemies.size():
			label.hide()
			continue
		label.text = enemies[i].data.name
		enemies[i].hp_changed.connect(update_enemy_label.bind(label))

func update_player_row(actor: battle_actor) -> void:
	var row = player_rows_by_actor[actor]
	row.get_node("Health").health = actor.hp
	row.get_node("HP").text = "%d/%d" % [actor.hp, actor.hp_max]
	row.modulate.a = 1.0 if actor.is_alive() else FAINTED_ALPHA

func update_enemy_label(actor: battle_actor, label: Label) -> void:
	label.modulate.a = 1.0 if actor.is_alive() else FAINTED_ALPHA

func mark_active(actor) -> void:
	var active_row = player_rows_by_actor.get(actor)
	for row in player_rows:
		var name_label: Label = row.get_node("Name")
		if row == active_row:
			name_label.add_theme_color_override("font_color", ACTIVE_NAME_COLOR)
		else:
			name_label.remove_theme_color_override("font_color")

func living(container: Node) -> Array[battle_actor]:
	var result: Array[battle_actor] = []
	for child in container.get_children():
		if child is battle_actor and child.is_alive() and not child.is_queued_for_deletion():
			result.append(child)
	return result

func can_act(actor) -> bool:
	return is_instance_valid(actor) and actor.is_alive()

func start_turn() -> void:
	for actor in living(player_target) + living(enemies_target):
		actor.guarding = false
		actor.reflect = 0.0
	choosers.clear()
	for actor in living(player_target):
		if not actor.is_charging():
			choosers.append(actor)
	chooser_index = 0
	choices.clear()
	prompt_chooser()

func prompt_chooser() -> void:
	if chooser_index >= choosers.size():
		resolve_turn()
		return
	var actor: battle_actor = choosers[chooser_index]
	var moves: Array[move_data] = actor.data.moves
	var buttons: Array = player_options.get_buttons()
	for i in buttons.size():
		var button: Button = buttons[i]
		button.visible = i < moves.size()
		if button.visible:
			button.text = " %s " % moves[i].name
	state = States.OPTIONS
	options.show()
	mark_active(actor)
	player_options.button_focus(0)
	show_move_info(0)

func show_move_info(index: int) -> void:
	if state != States.OPTIONS or chooser_index >= choosers.size():
		return
	var actor: battle_actor = choosers[chooser_index]
	if index >= actor.data.moves.size():
		return
	var move: move_data = actor.data.moves[index]
	message_box.set_message("What will %s do?\n%s: %s" % [actor.data.name, move.name, move.summary()])

func _on_player_options_button_focused(button: BaseButton) -> void:
	show_move_info(button.get_index())

func _on_player_options_button_pressed(button: BaseButton) -> void:
	if state != States.OPTIONS:
		return
	var actor: battle_actor = choosers[chooser_index]
	var move: move_data = actor.data.moves[button.get_index()]
	if move.target == move_data.Target.ONE_ENEMY:
		begin_targeting(move, enemies_target)
	elif move.target == move_data.Target.ONE_ALLY:
		begin_targeting(move, player_target)
	elif move.target == move_data.Target.SELF:
		choose(battle_action.new(actor, move, actor))
	else:
		choose(battle_action.new(actor, move, null))

func begin_targeting(move: move_data, party: SubMenu) -> void:
	pending_move = move
	state = States.TARGETS
	message_box.set_message("Use %s on who?" % move.name)
	focus_party(party)

func focus_party(party: SubMenu) -> void:
	var count: int = party.get_buttons().size()
	party.button_focus(clampi(party.index, 0, count - 1))

func on_target_pressed(button: BaseButton) -> void:
	if state != States.TARGETS:
		return
	var target = button as battle_actor
	if target == null:
		return
	var actor: battle_actor = choosers[chooser_index]
	var wants_foe: bool = pending_move.target == move_data.Target.ONE_ENEMY
	var is_foe: bool = target.is_player != actor.is_player
	if wants_foe != is_foe:
		return
	choose(battle_action.new(actor, pending_move, target))

func choose(action: battle_action) -> void:
	choices.append(action)
	chooser_index += 1
	prompt_chooser()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if state == States.OPTIONS and chooser_index > 0:
		chooser_index -= 1
		choices.pop_back()
		prompt_chooser()
	elif state == States.TARGETS:
		state = States.OPTIONS
		player_options.button_focus()
		show_move_info(player_options.index)

func lock_menus() -> void:
	get_viewport().gui_release_focus()
	for menu in [player_options, enemies_target, player_target]:
		menu.button_enable_focus(false)
	options.hide()
	cursor.hide()
	mark_active(null)

func resolve_turn() -> void:
	state = States.RESOLVING
	lock_menus()
	var enemies: Array[battle_actor] = living(enemies_target)
	var players: Array[battle_actor] = living(player_target)
	for actor in players + enemies:
		if actor.is_charging():
			choices.append(charge_action(actor))
	for enemy in enemies:
		if enemy.is_charging():
			continue
		var enemy_action: battle_action = enemy_ai.choose(enemy, enemies, players)
		if enemy_action:
			choices.append(enemy_action)
	choices.sort_custom(func(a: battle_action, b: battle_action) -> bool: return battle_action.goes_before(a, b))
	for action in choices:
		if not can_act(action.actor):
			continue
		await perform(action)
		if check_battle_over():
			return
	start_turn()

func charge_action(actor: battle_actor) -> battle_action:
	var target = actor.charge_target if is_instance_valid(actor.charge_target) else null
	var action = battle_action.new(actor, actor.charge_move, target)
	action.release = actor.charge_left <= 0
	return action

func perform(action: battle_action) -> void:
	var actor: battle_actor = action.actor
	var move: move_data = action.move
	if move.charge_turns > 0 and not action.release:
		if actor.is_charging():
			actor.charge_left -= 1
			await say("%s is still charging %s..." % [actor.data.name, move.name])
		else:
			actor.start_charge(move, action.target)
			await say("%s is charging up %s!" % [actor.data.name, move.name])
		return
	if action.release:
		actor.end_charge()
	await say("%s used %s!" % [actor.data.name, move.name])
	var targets: Array[battle_actor] = resolve_targets(action)
	if targets.is_empty():
		await say("But it failed!")
		return
	for target in targets:
		if not can_act(actor):
			break
		if move.kind == move_data.Kind.DAMAGE:
			await hit(actor, target, move)
		elif move.kind == move_data.Kind.HEAL:
			var before: int = target.hp
			await target.heal_hurt(move.power)
			await say("%s recovered %d HP." % [target.data.name, target.hp - before])
		elif move.kind == move_data.Kind.DEFEND:
			target.guarding = true
			target.reflect = move.reflect
			if move.reflect > 0:
				await say("%s is ready to counter!" % target.data.name)
			else:
				await say("%s is guarding." % target.data.name)
		elif move.kind == move_data.Kind.BUFF:
			target.damage_bonus += move.power
			await say("%s's damage rose by %d!" % [target.data.name, move.power])

func resolve_targets(action: battle_action) -> Array[battle_actor]:
	var actor: battle_actor = action.actor
	var foes: Array[battle_actor] = living(enemies_target if actor.is_player else player_target)
	var allies: Array[battle_actor] = living(player_target if actor.is_player else enemies_target)
	var target_type = action.move.target
	var result: Array[battle_actor] = []
	if target_type == move_data.Target.ALL_ENEMIES:
		result = foes
	elif target_type == move_data.Target.ALL_ALLIES:
		result = allies
	elif target_type == move_data.Target.SELF:
		result.append(actor)
	elif can_act(action.target):
		result.append(action.target)
	elif target_type == move_data.Target.ONE_ENEMY and not foes.is_empty():
		result.append(foes[0])
	return result

func hit(actor: battle_actor, target: battle_actor, move: move_data) -> void:
	var actor_name: String = actor.data.name
	var target_name: String = target.data.name
	var result: Dictionary = combat.roll_damage(actor, target, move)
	await target.heal_hurt(-result.amount)
	var fainted: bool = not target.is_alive()
	if result.crit:
		await say("A critical hit!")
	await say("%s took %d damage." % [target_name, result.amount])
	if fainted:
		await say("%s fainted!" % target_name)
	elif target.reflect > 0 and can_act(actor):
		var reflected: int = maxi(1, roundi(result.amount * target.reflect))
		await say("%s countered!" % target_name)
		await actor.heal_hurt(-reflected)
		var attacker_fainted: bool = not actor.is_alive()
		await say("%s took %d damage." % [actor_name, reflected])
		if attacker_fainted:
			await say("%s fainted!" % actor_name)

func check_battle_over() -> bool:
	if living(enemies_target).is_empty():
		finish(true)
		return true
	if living(player_target).is_empty():
		finish(false)
		return true
	return false

func finish(player_won: bool) -> void:
	state = States.OVER
	await say("You win!" if player_won else "Your party was defeated...")
	battle_ended.emit(player_won)
	results.show_result(player_won)

func say(text: String) -> void:
	print(text)
	await message_box.show_message(text)
	await get_tree().create_timer(MESSAGE_DELAY).timeout
