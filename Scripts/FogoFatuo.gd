extends Node2D

@onready var sprite = $Sprite2D
var float_time: float = 0.0

func _process(delta):
	float_time += delta * 4.0
	# Movimento místico flutuante do Fogo-Fátuo
	sprite.position.y = -sin(float_time) * 6.0
	sprite.scale.x = 1.0 + cos(float_time * 1.5) * 0.08
	sprite.scale.y = 1.0 + sin(float_time * 1.5) * 0.08