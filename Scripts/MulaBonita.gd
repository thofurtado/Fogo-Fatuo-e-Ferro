extends CharacterBody2D
class_name MulaBonita

@export var follow_target: Node2D
@export var follow_distance: float = 60.0
@export var max_leash_distance: float = 110.0
@export var max_speed: float = 115.0

@onready var sprite = $Sprite2D
@onready var rein_line = $ReinLine

var affinity: int = 100
var is_moving: bool = false
var bob_timer: float = 0.0
var sprite_ground_y: float = -16.0
var is_falling_ledge: bool = false
var panic_time: float = 0.0
var panic_cooldown: float = 0.0
var panic_direction: Vector2 = Vector2.ZERO
var panic_count: int = 0
var snort: AudioStreamPlayer2D
var directional_animator: Node

func get_rein_anchor() -> Vector2:
	var direction = directional_animator.direction if directional_animator else &"south"
	var height = sprite.texture.get_height()*sprite.scale.y
	var width = sprite.texture.get_width()*sprite.scale.x
	var offset = Vector2(0,-height*0.20)
	if direction == &"north": offset.y = -height*0.35
	elif direction == &"west": offset = Vector2(-width*0.35,-height*0.12)
	elif direction == &"east": offset = Vector2(width*0.35,-height*0.12)
	return global_position+sprite.position+offset

func startle(threat: Vector2) -> bool:
	if get_tree().paused or panic_cooldown > 0 or is_falling_ledge or not follow_target or follow_target.input_blocked:
		return false
	panic_direction = (global_position-threat).normalized()
	if panic_direction.is_zero_approx(): panic_direction = Vector2.LEFT
	panic_time = lerpf(1.0,0.7,clampf(float(affinity-60)/90.0,0,1))
	panic_cooldown = 10.0
	panic_count += 1
	if snort and DisplayServer.get_name() != "headless": snort.play()
	return true

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
	var base_y = sprite_ground_y + (water_sink_depth if in_water else 0.0)
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
	collision_layer = 2
	snort = AudioStreamPlayer2D.new()
	snort.stream = preload("res://Assets/SFX/mule_snort.wav")
	snort.volume_db = -19
	snort.max_distance = 360
	add_child(snort)
	sprite_ground_y = sprite.position.y
	var animator = preload("res://Scripts/DirectionalAnimator.gd").new()
	directional_animator = animator
	animator.frames = preload("res://Assets/Sprites/Characters/mule_walk.tres")
	add_child(animator)

func _physics_process(delta):
	panic_cooldown = maxf(0,panic_cooldown-delta)
	if not follow_target:
		return
		
	var target_pos = follow_target.global_position
	var direct_dist = global_position.distance_to(target_pos)
	
	# Se estiver executando o salto de escarpa, a física normal pausa para o tween
	if is_falling_ledge:
		return
	if follow_target.input_blocked:
		panic_time = 0
	if panic_time > 0:
		panic_time = maxf(0,panic_time-delta)
		var flee = panic_direction
		if test_move(global_transform,flee*12):
			flee = flee.rotated(PI/3)
			if test_move(global_transform,flee*12): flee = Vector2.ZERO
		velocity = flee * 130.0 * water_slow_factor
		move_and_slide()
		is_moving = velocity.length() > 2
		if global_position.distance_to(target_pos) > 66:
			follow_target.apply_leash_pull((global_position-target_pos).normalized()*70)
		if panic_time <= 0:
			breadcrumbs.clear()
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
		

	else:
		var effective_speed = max_speed * water_slow_factor
		velocity = velocity.move_toward(Vector2.ZERO, effective_speed * 8.0 * delta)
		if velocity.length() < 10.0:
			is_moving = false
			velocity = Vector2.ZERO

func add_affinity(amount: int):
	affinity = clamp(affinity + amount, 0, 150)

func _exit_tree():
	if is_instance_valid(snort):
		snort.stop()
		snort.stream = null
