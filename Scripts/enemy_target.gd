class_name enemy_target extends TextureButton

var hp_max: int = 10
var hp: int = hp_max

@onready var _hit: Timer = $Hit
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_animation_player.play("RESET")
	set_process(false)

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
	
