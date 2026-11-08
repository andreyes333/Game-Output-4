class_name combat extends RefCounted

const GUARD_MULTIPLIER := 0.5

static func roll_damage(attacker: battle_actor, target: battle_actor, move: move_data) -> Dictionary:
	var amount := float(move.power + attacker.data.damage)
	if target.guarding:
		amount *= GUARD_MULTIPLIER
	return {"amount": maxi(1, roundi(amount)), "crit": false}
