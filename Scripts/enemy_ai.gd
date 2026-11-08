class_name enemy_ai extends RefCounted

static func choose(actor: battle_actor, allies: Array[battle_actor], foes: Array[battle_actor]) -> battle_action:
	if foes.is_empty() or actor.data.moves.is_empty():
		return null
	var options: Array[move_data] = []
	var starts: Array[int] = []
	var total_rand_priority: int = 0
	for m in actor.data.moves:
		if m.kind == move_data.Kind.HEAL and allies.all(func(a): return a.hp == a.hp_max):
			continue
		options.append(m)
		starts.append(total_rand_priority)
		total_rand_priority += m.rand_priority
	var roll = randi_range(0, total_rand_priority - 1)
	if options.is_empty():
		return null
	var move: move_data = options[0]
	for i in range(len(starts) - 1, -1, -1):
		if roll >= starts[i]:
			move = options[i]
			break
	var target: battle_actor = null
	if move.target == move_data.Target.ONE_ENEMY:
		target = foes.pick_random()
	elif move.target == move_data.Target.ONE_ALLY:
		target = allies[0]
		for ally in allies:
			if target.hp_max - target.hp < ally.hp_max - ally.hp:
				target = ally
	elif move.target == move_data.Target.SELF:
		target = actor
	return battle_action.new(actor, move, target)
