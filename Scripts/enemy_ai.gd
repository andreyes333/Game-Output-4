class_name enemy_ai extends RefCounted

static func choose(actor: battle_actor, allies: Array[battle_actor], foes: Array[battle_actor]) -> battle_action:
	var skullmaxhp = 10
	var slimemaxhp = 20
	var snakemaxhp = 15
	
	if foes.is_empty() or actor.data.moves.is_empty():
		return null
	var move: move_data = actor.data.moves.pick_random() #go back for checking here -andre
	var target: battle_actor = null
	if move.target == move_data.Target.ONE_ENEMY:
		target = foes.pick_random()
	elif move.target == move_data.Target.ONE_ALLY:
		if allies[0].data.max_health <= skullmaxhp:
			target = allies[0]
		elif allies[1].data.max_health <= slimemaxhp:
			target == allies[1]
		elif allies[2].data.max_health <= snakemaxhp:
			target == allies[2]
	elif move.target == move_data.Target.SELF:
		target = actor
	return battle_action.new(actor, move, target)
