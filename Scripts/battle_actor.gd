class_name battle_actor extends TextureButton

signal died(actor: battle_actor)

@export var is_player : bool = false

var data : actor_data
var hp_max: int = 10
var hp: int = hp_max

@onready var _hit: Timer = $Hit
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	_animation_player.play("RESET")
	set_process(false)

func setup(actor: actor_data) -> void:
	data = actor
	hp_max = actor.max_health
	hp = hp_max
	texture_normal = actor.texture
	tooltip_text = actor.name
	_health_bar.init_health(hp_max)

func is_alive() -> bool:
	return hp > 0

#serves as the hit effect
func _process(_delta:float) -> void:
	modulate.a = randf()

func _on_focus_entered() -> void:
	_animation_player.play("highlight")

func _on_focus_exited() -> void:
	_animation_player.play("RESET")

func heal_hurt(value: int) -> void:
	hp = clamp(hp + value, 0, hp_max)
	_health_bar.health = hp
	if value < 0:
		set_process(true)
		_hit.start()
		await _hit.timeout
		set_process(false)
		modulate.a = 1.0
	if hp == 0:
		died.emit(self)
		queue_free()
