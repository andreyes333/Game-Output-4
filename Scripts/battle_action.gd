class_name battle_action extends RefCounted

var actor: battle_actor
var move: move_data
var target: battle_actor
var release: bool = false
var tiebreak: float = randf()

func _init(p_actor: battle_actor, p_move: move_data, p_target: battle_actor) -> void:
	actor = p_actor
	move = p_move
	target = p_target

static func goes_before(a: battle_action, b: battle_action) -> bool:
	if a.move.priority != b.move.priority:
		return a.move.priority > b.move.priority
	if a.actor.data.speed != b.actor.data.speed:
		return a.actor.data.speed > b.actor.data.speed
	return a.tiebreak > b.tiebreak
