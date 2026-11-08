class_name combat extends RefCounted

const GUARD_MULTIPLIER := 0.5

static func roll_damage(attacker: battle_actor, target: battle_actor, move: move_data) -> Dictionary:
	attacker.data.damage += randi_range(-3, 3) #determines high rolls or low rolls for damage
	var amount := float(move.power + attacker.data.damage)
	if target.guarding:
		amount *= GUARD_MULTIPLIER
	return {"amount": maxi(1, roundi(amount)), "crit": false}
