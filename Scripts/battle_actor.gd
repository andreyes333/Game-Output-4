class_name battle_actor extends TextureButton

signal died(actor: battle_actor)
signal hp_changed(actor: battle_actor)

const CHARGE_TINT = Color(1.0, 0.85, 0.4)

@export var is_player : bool = false

var data : actor_data
var hp_max: int = 10
var hp: int = hp_max
var guarding: bool = false
var reflect: float = 0.0
var damage_bonus: int = 0
var charge_move: move_data = null
var charge_target = null
var charge_left: int = 0

@onready var hit_timer: Timer = $Hit
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = get_node_or_null("HealthBar")
@onready var hp_label: Label = get_node_or_null("HealthBar/HP")

func _ready() -> void:
	animation_player.play("RESET")
	set_process(false)

func setup(actor: actor_data) -> void:
	data = actor
	hp_max = actor.max_health
	hp = hp_max
	texture_normal = actor.texture
	tooltip_text = actor.name
	if health_bar:
		health_bar.init_health(hp_max)
	update_hp_label()

func update_hp_label() -> void:
	if hp_label:
		hp_label.text = "%d/%d" % [hp, hp_max]

func is_alive() -> bool:
	return hp > 0

func is_charging() -> bool:
	return charge_move != null

func start_charge(move: move_data, target) -> void:
	charge_move = move
	charge_target = target
	charge_left = move.charge_turns - 1
	modulate = Color(CHARGE_TINT, modulate.a)

func end_charge() -> void:
	charge_move = null
	charge_target = null
	charge_left = 0
	modulate = Color(Color.WHITE, modulate.a)

#serves as the hit effect
func _process(_delta:float) -> void:
	modulate.a = randf()

func _on_focus_entered() -> void:
	animation_player.play("highlight")

func _on_focus_exited() -> void:
	animation_player.play("RESET")

func heal_hurt(value: int) -> void:
	hp = clampi(hp + value, 0, hp_max)
	if health_bar:
		health_bar.health = hp
	update_hp_label()
	hp_changed.emit(self)
	if value < 0:
		set_process(true)
		hit_timer.start()
		await hit_timer.timeout
		set_process(false)
		modulate.a = 1.0
	if hp == 0:
		died.emit(self)
		queue_free()
