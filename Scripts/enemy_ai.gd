class_name enemy_ai extends RefCounted



static func choose(actor: battle_actor, allies: Array[battle_actor], foes: Array[battle_actor]) -> battle_action:
	if foes.is_empty() or actor.data.moves.is_empty():
		return null
	var move: move_data = actor.data.moves.pick_random() #go back for checking here -andre
	var target: battle_actor = null
	var allymissinghp : int
	var targetmissinghp : int
	if move.target == move_data.Target.ONE_ENEMY:
		target = foes.pick_random()
	elif move.target == move_data.Target.ONE_ALLY:
		target = allies[0]
		for ally in allies:
			allymissinghp = ally.hp_max - ally.hp
			targetmissinghp = target.hp_max - target.hp
			if targetmissinghp < allymissinghp:
				target = ally
	elif move.target == move_data.Target.SELF:
		target = actor
	return battle_action.new(actor, move, target)
