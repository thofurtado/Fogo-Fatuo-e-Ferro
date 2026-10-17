extends CharacterBody2D
class_name TropeiroTilemapController

signal attack_requested(target: Node2D, damage: int)
signal attack_windup_started(direction: Vector2)
signal attack_window_started(direction: Vector2)
signal health_changed(current: int, maximum: int)
signal died

@export_group("Movimento")
@export_range(1.0, 500.0, 1.0) var move_speed: float = 160.0
@export_range(1.0, 3000.0, 1.0) var acceleration: float = 1400.0
@export_range(1.0, 4000.0, 1.0) var braking: float = 1800.0
@export var movement_enabled: bool = true

@export_group("Vida")
@export_range(1, 100, 1) var max_health: int = 24
@export var sync_health_with_game_manager: bool = true

@export_group("Combate — Tropeiro")
@export_range(1, 50, 1) var attack_damage: int = 3
@export_range(0.05, 1.0, 0.05) var attack_cooldown: float = 0.35
@export_range(0.0, 1.0, 0.01) var attack_windup: float = 0.18
@export_range(0.05, 0.5, 0.01) var attack_window: float = 0.12
@export_range(0.0, 100.0, 1.0) var attack_area_offset: float = 26.0
@export var attack_keycode: int = KEY_J

@onready var animation_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var attack_area = get_node_or_null("AttackArea") as Area2D

var facing_direction: StringName = &"down"
var current_health: int = 24
var attack_cooldown_left: float = 0.0
var attack_windup_left: float = 0.0
var attack_window_left: float = 0.0
var attack_direction: Vector2 = Vector2.DOWN
var attack_hit_targets: Dictionary = {}


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")
	current_health = _load_initial_health()
	if attack_area != null:
		attack_area.monitoring = true
		_update_attack_area_position()
	_sync_health_to_game_manager(false)
	health_changed.emit(current_health, max_health)


func _physics_process(delta: float) -> void:
	var direction := _read_direction()
	if not movement_enabled or current_health <= 0:
		direction = Vector2.ZERO

	if direction != Vector2.ZERO and attack_windup_left <= 0.0 and attack_window_left <= 0.0:
		_update_facing(direction)

	var target_velocity := direction * move_speed
	var rate := acceleration if direction != Vector2.ZERO else braking
	velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()

	attack_cooldown_left = maxf(0.0, attack_cooldown_left - delta)
	if not movement_enabled or current_health <= 0:
		attack_windup_left = 0.0
		attack_window_left = 0.0
	else:
		if attack_windup_left > 0.0:
			attack_windup_left = maxf(0.0, attack_windup_left - delta)
			if attack_windup_left <= 0.0:
				_begin_attack_window()
		if attack_window_left > 0.0:
			_update_attack_area_position()
			_scan_attack_targets()
			attack_window_left = maxf(0.0, attack_window_left - delta)
	_update_animation()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == attack_keycode:
		request_attack()


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO
		attack_windup_left = 0.0
		attack_window_left = 0.0


func request_attack() -> void:
	# Também pode ser chamado por um botão de toque ou por outra interface.
	if current_health <= 0 or not movement_enabled or attack_area == null or attack_cooldown_left > 0.0:
		return
	attack_cooldown_left = attack_cooldown
	attack_windup_left = attack_windup
	attack_window_left = 0.0
	attack_hit_targets.clear()
	attack_direction = _facing_vector()
	_update_attack_area_position()
	attack_windup_started.emit(attack_direction)
	if attack_windup_left <= 0.0:
		_begin_attack_window()


func take_damage(amount: int, _source_position: Vector2 = Vector2.ZERO) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = maxi(0, current_health - amount)
	_sync_health_to_game_manager()
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		movement_enabled = false
		velocity = Vector2.ZERO
		attack_windup_left = 0.0
		attack_window_left = 0.0
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = mini(max_health, current_health + amount)
	_sync_health_to_game_manager()
	health_changed.emit(current_health, max_health)


func _read_direction() -> Vector2:
	# ui_* aceita setas/controles do Input Map; WASD preserva o padrão do projeto.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	return direction.limit_length(1.0)


func _update_facing(direction: Vector2) -> void:
	# Em diagonal, usa o eixo dominante; em empate, conserva a última orientação.
	if absf(direction.x) > absf(direction.y):
		facing_direction = &"right" if direction.x > 0.0 else &"left"
	elif absf(direction.y) > absf(direction.x):
		facing_direction = &"down" if direction.y > 0.0 else &"up"


func _update_attack_area_position() -> void:
	if attack_area == null:
		return
	var direction := attack_direction if attack_windup_left > 0.0 or attack_window_left > 0.0 else _facing_vector()
	attack_area.position = direction * attack_area_offset


func _facing_vector() -> Vector2:
	match facing_direction:
		&"up":
			return Vector2.UP
		&"left":
			return Vector2.LEFT
		&"right":
			return Vector2.RIGHT
	return Vector2.DOWN


func _begin_attack_window() -> void:
	attack_windup_left = 0.0
	attack_window_left = attack_window
	attack_window_started.emit(attack_direction)


func _scan_attack_targets() -> void:
	if attack_area == null:
		return
	for body in attack_area.get_overlapping_bodies():
		if not is_instance_valid(body) or not body.is_in_group("enemy"):
			continue
		var instance_id: int = body.get_instance_id()
		if attack_hit_targets.has(instance_id):
			continue
		attack_hit_targets[instance_id] = true
		attack_requested.emit(body, attack_damage)


func _load_initial_health() -> int:
	max_health = maxi(1, max_health)
	if not sync_health_with_game_manager:
		return max_health
	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager == null:
		return max_health
	var archetype: Variant = game_manager.get("current_archetype")
	if not (archetype is Dictionary):
		return max_health
	max_health = maxi(1, int(archetype.get("vida_max", max_health)))
	return clampi(int(archetype.get("vida_atual", max_health)), 0, max_health)


func _sync_health_to_game_manager(emit_stat: bool = true) -> void:
	if not sync_health_with_game_manager:
		return
	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager == null:
		return
	var archetype: Variant = game_manager.get("current_archetype")
	if not (archetype is Dictionary) or archetype.is_empty():
		return
	archetype["vida_atual"] = current_health
	game_manager.set("current_archetype", archetype)
	if emit_stat and game_manager.has_signal("stat_changed"):
		game_manager.emit_signal("stat_changed", "vida_atual", current_health)


func _update_animation() -> void:
	if animation_sprite == null or animation_sprite.sprite_frames == null:
		return
	var frames: SpriteFrames = animation_sprite.sprite_frames
	var is_walking := velocity.length_squared() > 25.0
	var prefix := "walk" if is_walking else "idle"
	var clip := StringName("%s_%s" % [prefix, String(facing_direction)])
	if not frames.has_animation(clip):
		return
	if animation_sprite.animation != clip or (is_walking and not animation_sprite.is_playing()):
		animation_sprite.play(clip)
