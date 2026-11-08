class_name move_data extends Resource

enum Kind { DAMAGE, HEAL, DEFEND, BUFF }
enum Target { ONE_ENEMY, ALL_ENEMIES, SELF, ONE_ALLY, ALL_ALLIES }

@export var name : String
@export var kind : Kind = Kind.DAMAGE
@export var target : Target = Target.ONE_ENEMY
@export var power : int = 5
@export var priority : int = 0
@export var charge_turns : int = 0
@export var rand_priority : int = 1
@export var reflect : float = 0.0

func summary() -> String:
	var parts = PackedStringArray()
	if kind == Kind.DAMAGE:
		parts.append("Power %d" % power)
	elif kind == Kind.HEAL:
		parts.append("Heal %d" % power)
	elif kind == Kind.DEFEND:
		parts.append("Halve damage")
	elif kind == Kind.BUFF:
		parts.append("+%d damage" % power)
	if reflect > 0:
		parts.append("counters %d%%" % roundi(reflect * 100))
	if target == Target.ALL_ENEMIES:
		parts.append("all foes")
	elif target == Target.ALL_ALLIES:
		parts.append("all allies")
	if priority > 0:
		parts.append("goes first")
	elif priority < 0:
		parts.append("goes last")
	if charge_turns > 0:
		parts.append("charges %d turn%s" % [charge_turns, "" if charge_turns == 1 else "s"])
	return ", ".join(parts)
