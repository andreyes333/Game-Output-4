class_name combat extends RefCounted

const GUARD_MULTIPLIER := 0.5
const CRIT_MULT = 1.5

static func roll_damage(attacker: battle_actor, target: battle_actor, move: move_data) -> Dictionary:
	var amount := float(move.power + attacker.data.damage)
	var crit_check = null
	
	var crit_chance = randf_range(0, 1)
	
	if crit_chance <= 0.20:
		crit_check = true
		amount *= CRIT_MULT
	else:
		crit_check = false
	
	amount += randi_range(-2, 2) #determines damage high rolls or low rolls
	if target.guarding:
		amount *= GUARD_MULTIPLIER
	return {"amount": maxi(1, roundi(amount)), "crit": crit_check}
