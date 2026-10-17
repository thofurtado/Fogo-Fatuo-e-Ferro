extends CharacterBody2D
class_name TropeiroPlayer

signal attack_requested(target: Node2D, damage: int)
signal attack_windup_started(direction: Vector2)
signal attack_window_started(direction: Vector2)
signal health_changed(current: int, maximum: int)
signal died

@export_group("Movimento")
@export var speed: float = 95.0
@export var camera_zoom: Vector2 = Vector2(1.35, 1.35)
@export var movement_enabled: bool = true

@export_group("Vida")
@export_range(1, 100, 1) var max_health: int = 24
@export var sync_health_with_game_manager: bool = true

@export_group("Combate")
@export_range(1, 50, 1) var attack_damage: int = 3
@export_range(0.05, 1.0, 0.05) var attack_cooldown: float = 0.35
@export_range(0.0, 1.0, 0.01) var attack_windup: float = 0.18
@export_range(0.05, 0.5, 0.01) var attack_window: float = 0.12
@export_range(0.0, 100.0, 1.0) var attack_area_offset: float = 26.0
@export var attack_keycode: int = KEY_J

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = get_node_or_null("AttackArea") as Area2D

var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var bob_timer: float = 0.0
var is_falling_ledge: bool = false
var current_health: int = 24
var attack_cooldown_left: float = 0.0
var attack_windup_left: float = 0.0
var attack_window_left: float = 0.0
var attack_direction: Vector2 = Vector2.DOWN
var attack_hit_targets: Dictionary = {}

# Mecânica de água / riacho
var water_zones_count: int = 0
var in_water: bool = false
var water_slow_factor: float = 1.0
var water_sink_depth: float = 0.0


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")
	var cam := get_node_or_null("Camera2D") as Camera2D
	if cam != null:
		cam.zoom = camera_zoom
	current_health = _load_initial_health()
	if attack_area != null:
		attack_area.monitoring = true
		_update_attack_area_position()
	_sync_health_to_game_manager(false)
	health_changed.emit(current_health, max_health)


func enter_water_zone(slow_factor: float = 0.35, sink_depth: float = 3.5) -> void:
	water_zones_count += 1
	in_water = true
	water_slow_factor = slow_factor
	water_sink_depth = sink_depth


func exit_water_zone() -> void:
	water_zones_count = maxi(0, water_zones_count - 1)
	if water_zones_count == 0:
		in_water = false
		water_slow_factor = 1.0
		water_sink_depth = 0.0


func drop_down_ledge(target_y: float, on_finished: Callable = Callable()) -> void:
	if is_falling_ledge:
		return
	is_falling_ledge = true
	velocity = Vector2.ZERO

	# Hop animation no sprite (arco de salto na pedra).
	var base_y := water_sink_depth if in_water else 0.0
	var hop := create_tween()
	hop.tween_property(sprite, "position:y", base_y - 18.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.tween_property(sprite, "position:y", base_y, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Movimento para baixo até o nível inferior.
	var move := create_tween()
	move.tween_property(self, "global_position:y", target_y, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await move.finished

	is_falling_ledge = false
	if on_finished.is_valid():
		on_finished.call()


func _physics_process(delta: float) -> void:
	if is_falling_ledge:
		return

	var input_vector := Vector2.ZERO
	if movement_enabled and current_health > 0:
		if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
			input_vector.x += 1.0
		if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
			input_vector.x -= 1.0
		if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
			input_vector.y += 1.0
		if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
			input_vector.y -= 1.0

	var effective_speed := speed * water_slow_factor
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		if attack_windup_left <= 0.0 and attack_window_left <= 0.0:
			facing_direction = input_vector
		velocity = input_vector * effective_speed
		is_moving = true
		if input_vector.x > 0.1:
			sprite.flip_h = false
		elif input_vector.x < -0.1:
			sprite.flip_h = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, effective_speed * 10.0 * delta)
		is_moving = false

	move_and_slide()

	# Empurrar objetos físicos (barris e caixotes).
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is CharacterBody2D and collider.is_in_group("pushable"):
			collider.velocity = -collision.get_normal() * (effective_speed * 0.6)
			collider.move_and_slide()

	_update_attack(delta)

	# Animação sutil de passos e imersão visual na água.
	if is_moving:
		var bob_freq := 4.5 if in_water else 7.5
		bob_timer += delta * bob_freq
		var bob_offset := sin(bob_timer) * (1.0 if in_water else 1.6)
		sprite.position.y = bob_offset + (water_sink_depth if in_water else 0.0)
	else:
		bob_timer = 0.0
		sprite.position.y = water_sink_depth if in_water else 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == attack_keycode:
		request_attack()


func request_attack() -> void:
	if current_health <= 0 or not movement_enabled or is_falling_ledge or attack_area == null or attack_cooldown_left > 0.0:
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


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO
		attack_windup_left = 0.0
		attack_window_left = 0.0


func take_damage(amount: int, _source_position: Vector2 = Vector2.ZERO) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = maxi(0, current_health - amount)
	_sync_health_to_game_manager()
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		set_movement_enabled(false)
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = mini(max_health, current_health + amount)
	_sync_health_to_game_manager()
	health_changed.emit(current_health, max_health)


func refresh_health_from_game_manager() -> void:
	if not sync_health_with_game_manager:
		return
	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager == null:
		return
	var archetype: Variant = game_manager.get("current_archetype")
	if not (archetype is Dictionary) or archetype.is_empty():
		return
	max_health = maxi(1, int(archetype.get("vida_max", max_health)))
	var was_alive := current_health > 0
	current_health = clampi(int(archetype.get("vida_atual", current_health)), 0, max_health)
	health_changed.emit(current_health, max_health)
	if current_health == 0 and was_alive:
		set_movement_enabled(false)
		died.emit()


func _update_attack(delta: float) -> void:
	attack_cooldown_left = maxf(0.0, attack_cooldown_left - delta)
	if not movement_enabled or current_health <= 0:
		attack_windup_left = 0.0
		attack_window_left = 0.0
		return
	if attack_windup_left > 0.0:
		attack_windup_left = maxf(0.0, attack_windup_left - delta)
		if attack_windup_left <= 0.0:
			_begin_attack_window()
	if attack_window_left > 0.0:
		_update_attack_area_position()
		_scan_attack_targets()
		attack_window_left = maxf(0.0, attack_window_left - delta)


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


func _facing_vector() -> Vector2:
	if absf(facing_direction.x) > absf(facing_direction.y):
		return Vector2.RIGHT if facing_direction.x > 0.0 else Vector2.LEFT
	if absf(facing_direction.y) > 0.001:
		return Vector2.DOWN if facing_direction.y > 0.0 else Vector2.UP
	return Vector2.DOWN


func _update_attack_area_position() -> void:
	if attack_area == null:
		return
	var direction := attack_direction if attack_windup_left > 0.0 or attack_window_left > 0.0 else _facing_vector()
	attack_area.position = direction * attack_area_offset


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
