class_name enemy_ai extends RefCounted

static func choose(actor: battle_actor, allies: Array[battle_actor], foes: Array[battle_actor]) -> battle_action:
	if foes.is_empty() or actor.data.moves.is_empty():
		return null
	var move: move_data = actor.data.moves[0]
	var target: battle_actor = null
	if move.target == move_data.Target.ONE_ENEMY:
		target = foes[0]
	elif move.target == move_data.Target.ONE_ALLY:
		target = allies[0]
	elif move.target == move_data.Target.SELF:
		target = actor
	return battle_action.new(actor, move, target)
