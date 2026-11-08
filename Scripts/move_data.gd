class_name move_data extends Resource

enum Kind { DAMAGE, HEAL, DEFEND, BUFF }
enum Target { ONE_ENEMY, ALL_ENEMIES, SELF, ONE_ALLY }

@export var name : String
@export var kind : Kind = Kind.DAMAGE
@export var target : Target = Target.ONE_ENEMY
@export var power : int = 5
@export var priority : int = 0
@export var charge_turns : int = 0
