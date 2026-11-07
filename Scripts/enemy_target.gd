class_name enemy_target extends TextureButton

var data : enemy_data
var hp_max: int = 10
var hp: int = hp_max

@onready var _hit: Timer = $Hit
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	_animation_player.play("RESET")
	set_process(false)

func setup_enemy(enemy: enemy_data) -> void:
	data = enemy
	hp_max = enemy.max_health
	hp = hp_max
		
	texture_normal = enemy.texture
	tooltip_text = enemy.name
	
	if _health_bar and _health_bar.has_method("init_health"):
		_health_bar.init_health(hp_max)

#serves as the hit effect
func _process(_delta:float) -> void:
	modulate.a = randf()

func _on_focus_entered() -> void:
	_animation_player.play("highlight")

func _on_focus_exited() -> void:
	_animation_player.play("RESET")
	
func heal_hurt(value: int) -> void:
	hp = clamp(hp + value, 0, hp_max)
	if value < 0:
		set_process(true)
		_hit.start()
		await _hit.timeout
		set_process(false)
		modulate.a = 1.0
	
