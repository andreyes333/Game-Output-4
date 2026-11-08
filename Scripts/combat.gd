class_name combat extends RefCounted

const GUARD_MULTIPLIER = 0.5
const CRIT_MULTIPLIER = 1.5
const CRIT_THRESHOLD = 0.8

static func roll_damage(attacker: battle_actor, target: battle_actor, move: move_data) -> Dictionary:
	var amount: float = float(move.power + attacker.data.damage + attacker.damage_bonus)

	var crit_check = false
	var crit_roll = randf_range(0, 1)
	
	if crit_roll >= CRIT_THRESHOLD:
		crit_check = true
		amount *= CRIT_MULTIPLIER
	
	amount += randi_range(-2, 2) #determines damage high rolls or low rolls
	if target.guarding:
		amount *= GUARD_MULTIPLIER
	return {"amount": maxi(1, roundi(amount)), "crit": crit_check}
