extends CharacterBody2D
class_name MulaBonita

@export var follow_target: Node2D
@export var follow_distance: float = 46.0
@export var max_leash_distance: float = 110.0
@export var max_speed: float = 115.0

@onready var sprite = $Sprite2D
@onready var rein_line = $ReinLine

var affinity: int = 100
var is_moving: bool = false
var bob_timer: float = 0.0
var is_falling_ledge: bool = false

# Mecânica de água / riacho
var water_zones_count: int = 0
var in_water: bool = false
var water_slow_factor: float = 1.0
var water_sink_depth: float = 0.0

# Histórico de passos do condutor para fazer curvas sem cortar quina de paredes
var breadcrumbs: Array[Vector2] = []
const BREADCRUMB_INTERVAL: float = 18.0

func enter_water_zone(slow_factor: float = 0.35, sink_depth: float = 3.5):
	water_zones_count += 1
	in_water = true
	water_slow_factor = slow_factor
	water_sink_depth = sink_depth

func exit_water_zone():
	water_zones_count = max(0, water_zones_count - 1)
	if water_zones_count == 0:
		in_water = false
		water_slow_factor = 1.0
		water_sink_depth = 0.0

func drop_down_ledge(target_y: float, on_finished: Callable = Callable()):
	if is_falling_ledge:
		return
	is_falling_ledge = true
	velocity = Vector2.ZERO
	
	# Pulinho animado da Mula descendo a pedra
	var base_y = water_sink_depth if in_water else 0.0
	var hop = create_tween()
	hop.tween_property(sprite, "position:y", base_y - 14.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.tween_property(sprite, "position:y", base_y, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	var move = create_tween()
	move.tween_property(self, "global_position:y", target_y, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await move.finished
	
	is_falling_ledge = false
	if on_finished.is_valid():
		on_finished.call()

func _ready():
	if rein_line:
		rein_line.width = 2.0
		rein_line.default_color = Color(0.45, 0.28, 0.15, 0.85)

func _physics_process(delta):
	if not follow_target:
		return
		
	var target_pos = follow_target.global_position
	var direct_dist = global_position.distance_to(target_pos)
	
	# Linha visual da rédea elástica (sempre atualizada, mesmo durante o salto)
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

	# Se estiver executando o salto de escarpa, a física normal pausa para o tween
	if is_falling_ledge:
		return
		
	# Grava rastro de passos do Tropeiro para fazer as curvas da trilha
	if breadcrumbs.is_empty() or breadcrumbs.back().distance_to(target_pos) >= BREADCRUMB_INTERVAL:
		breadcrumbs.append(target_pos)
		if breadcrumbs.size() > 20:
			breadcrumbs.pop_front()
	
	# O alvo imediato da mula é o ponto de rastro por onde o Tropeiro passou
	while breadcrumbs.size() > 1 and global_position.distance_to(breadcrumbs[0]) < 20.0:
		breadcrumbs.pop_front()
		
	var move_target = breadcrumbs[0] if not breadcrumbs.is_empty() else target_pos
		
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
		
		var effective_speed = max_speed * water_slow_factor
		velocity = velocity.move_toward(dir * (effective_speed * tension), effective_speed * 6.0 * delta)
		move_and_slide()
		is_moving = true
		
		# Vira o sprite conforme a direção
		if velocity.x > 5.0:
			sprite.flip_h = false
		elif velocity.x < -5.0:
			sprite.flip_h = true
	else:
		var effective_speed = max_speed * water_slow_factor
		velocity = velocity.move_toward(Vector2.ZERO, effective_speed * 8.0 * delta)
		if velocity.length() < 10.0:
			is_moving = false
			velocity = Vector2.ZERO
		
	# Efeito sutil de passos (bobbing + afundamento na água)
	if is_moving:
		var bob_freq = 4.5 if in_water else 7.5
		bob_timer += delta * (velocity.length() / max_speed) * bob_freq
		var bob_offset = sin(bob_timer) * (1.0 if in_water else 1.5)
		sprite.position.y = bob_offset + (water_sink_depth if in_water else 0.0)
	else:
		bob_timer = 0.0
		sprite.position.y = (water_sink_depth if in_water else 0.0)

func add_affinity(amount: int):
	affinity = clamp(affinity + amount, 0, 150)
