extends CharacterBody2D
class_name MulaBonita

@export var follow_target: Node2D
@export var follow_distance: float = 46.0
@export var max_leash_distance: float = 110.0
@export var max_speed: float = 220.0

@onready var sprite = $Sprite2D
@onready var rein_line = $ReinLine

var affinity: int = 100
var is_moving: bool = false
var bob_timer: float = 0.0

# Histórico de passos do condutor para fazer curvas sem cortar quina de paredes
var breadcrumbs: Array[Vector2] = []
const BREADCRUMB_INTERVAL: float = 18.0

func _ready():
	if rein_line:
		rein_line.width = 2.0
		rein_line.default_color = Color(0.45, 0.28, 0.15, 0.85)

func _physics_process(delta):
	if not follow_target:
		return
		
	var target_pos = follow_target.global_position
	var direct_dist = global_position.distance_to(target_pos)
	
	# Grava rastro de passos do Tropeiro para fazer as curvas da trilha
	if breadcrumbs.is_empty() or breadcrumbs.back().distance_to(target_pos) >= BREADCRUMB_INTERVAL:
		breadcrumbs.append(target_pos)
		if breadcrumbs.size() > 20:
			breadcrumbs.pop_front()
	
	# O alvo imediato da mula é o ponto de rastro por onde o Tropeiro passou
	while breadcrumbs.size() > 1 and global_position.distance_to(breadcrumbs[0]) < 20.0:
		breadcrumbs.pop_front()
		
	var move_target = breadcrumbs[0] if not breadcrumbs.is_empty() else target_pos
	
	# Linha visual da rédea elástica
	if rein_line:
		rein_line.clear_points()
		rein_line.add_point(Vector2.ZERO)
		var local_target = to_local(target_pos + Vector2(0, 8))
		rein_line.add_point(local_target)
		# Tensão visual da corda: afina e fica mais esticada se puxar muito
		if direct_dist > follow_distance * 1.5:
			rein_line.width = 1.5
			rein_line.default_color = Color(0.55, 0.22, 0.12, 0.9)
		else:
			rein_line.width = 2.0
			rein_line.default_color = Color(0.45, 0.28, 0.15, 0.85)
		
	if direct_dist > follow_distance:
		var dir = (move_target - global_position).normalized()
		
		# Modelo elástico de mola (quanto mais estica a corda, maior a aceleração da mula)
		var stretch = direct_dist - follow_distance
		var tension = clamp(stretch / 32.0, 0.6, 2.2)
		
		# Se esticar demais por ficar enroscada em quina estreita, aplica puxão de desatolamento
		if direct_dist > max_leash_distance:
			tension = 2.8
			# Se a corda esticar ao extremo (>170px), dá um puxão assistido em direção ao rastro
			if direct_dist > 170.0:
				global_position = global_position.move_toward(move_target, 6.0)
		
		velocity = velocity.move_toward(dir * (max_speed * tension), max_speed * 6.0 * delta)
		move_and_slide()
		is_moving = true
		
		# Vira o sprite conforme a direção
		if velocity.x > 5.0:
			sprite.flip_h = false
		elif velocity.x < -5.0:
			sprite.flip_h = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, max_speed * 8.0 * delta)
		if velocity.length() < 10.0:
			is_moving = false
			velocity = Vector2.ZERO
		
	# Efeito sutil de passos (bobbing)
	if is_moving:
		bob_timer += delta * (velocity.length() / max_speed) * 12.0
		sprite.position.y = sin(bob_timer) * 2.0
	else:
		bob_timer = 0.0
		sprite.position.y = 0.0

func add_affinity(amount: int):
	affinity = clamp(affinity + amount, 0, 150)
