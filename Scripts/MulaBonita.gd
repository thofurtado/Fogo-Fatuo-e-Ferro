extends CharacterBody2D
class_name MulaBonita

@export var follow_target: Node2D
@export var follow_distance: float = 55.0
@export var max_speed: float = 210.0

@onready var sprite = $Sprite2D
@onready var rein_line = $ReinLine

var affinity: int = 100
var is_moving: bool = false
var bob_timer: float = 0.0

func _ready():
	if rein_line:
		rein_line.width = 2.0
		rein_line.default_color = Color(0.45, 0.28, 0.15, 0.85)

func _physics_process(delta):
	if not follow_target:
		return
		
	var target_pos = follow_target.global_position
	var dist = global_position.distance_to(target_pos)
	
	# Atualiza a linha da rédea de couro conectando o Tropeiro à Mula
	if rein_line:
		rein_line.clear_points()
		rein_line.add_point(Vector2.ZERO)
		var local_target = to_local(target_pos + Vector2(0, 10))
		rein_line.add_point(local_target)
		
	if dist > follow_distance:
		var dir = (target_pos - global_position).normalized()
		var speed_factor = clamp((dist - follow_distance) / 40.0, 0.5, 1.3)
		velocity = dir * max_speed * speed_factor
		move_and_slide()
		is_moving = true
		
		# Vira o sprite conforme a direção
		if dir.x > 0.1:
			sprite.flip_h = false
		elif dir.x < -0.1:
			sprite.flip_h = true
	else:
		velocity = Vector2.ZERO
		is_moving = false
		
	# Efeito sutil de passos (bobbing)
	if is_moving:
		bob_timer += delta * 10.0
		sprite.position.y = sin(bob_timer) * 2.0
	else:
		bob_timer = 0.0
		sprite.position.y = 0.0

func add_affinity(amount: int):
	affinity = clamp(affinity + amount, 0, 150)
