extends Area2D

@onready var sprite = $Sprite2D
var pulse_time: float = 0.0

func _process(delta):
	pulse_time += delta * 4.0
	var s = 1.0 + sin(pulse_time) * 0.12
	sprite.scale = Vector2(s, s)