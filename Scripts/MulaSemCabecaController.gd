extends CharacterBody2D
class_name MulaSemCabecaController

signal attack_requested(target: Node2D, damage: int)
signal defeated(enemy: Node2D)
signal health_changed(current: int, maximum: int)
signal state_changed(previous_state: int, new_state: int)

enum State { IDLE, CHASE, WINDUP, CHARGE, RECOVER, STAGGER, DEFEATED }
const STATE_NAMES: Array[String] = ["IDLE", "CHASE", "WINDUP", "CHARGE", "RECOVER", "STAGGER", "DEFEATED"]

@export var player_group: StringName = &"player"
@export_range(1, 65535, 1) var player_collision_mask: int = 2

@export_group("Vida")
@export_range(1, 100, 1) var max_health: int = 12
@export_range(1, 100, 1) var health: int = 12

@export_group("Perseguição")
@export_range(1.0, 400.0, 1.0) var chase_speed: float = 90.0
@export_range(1.0, 4000.0, 1.0) var braking: float = 1600.0

@export_group("Investida — balanceamento")
@export_range(1.0, 600.0, 1.0) var charge_speed: float = 230.0
@export_range(1.0, 300.0, 1.0) var charge_trigger_distance: float = 112.0
@export_range(0.05, 3.0, 0.05) var windup_seconds: float = 0.55
@export_range(0.05, 2.0, 0.05) var charge_seconds: float = 0.45
@export_range(0.05, 3.0, 0.05) var recover_seconds: float = 0.8
@export_range(0, 100, 1) var charge_damage: int = 3
@export_range(0.0, 80.0, 1.0) var hitbox_forward_offset: float = 28.0

@export_group("Reação a dano")
@export_range(0.05, 2.0, 0.05) var stagger_seconds: float = 0.4
@export_range(0.0, 1000.0, 1.0) var stagger_knockback: float = 110.0

@onready var detection_area = get_node_or_null("DetectionArea") as Area2D
@onready var charge_hitbox = get_node_or_null("ChargeHitbox") as Area2D
@onready var body_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
@onready var animation_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var current_state: State = State.IDLE
var state_time_left: float = 0.0
var target: CharacterBody2D
var target_in_range: bool = false
var charge_direction: Vector2 = Vector2.RIGHT
var facing_direction: Vector2 = Vector2.DOWN
var hit_already_this_charge: bool = false


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("enemy")
	max_health = maxi(1, max_health)
	health = clampi(health, 1, max_health)
	health_changed.emit(health, max_health)
	if detection_area != null:
		detection_area.collision_mask = player_collision_mask
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
	if charge_hitbox != null:
		charge_hitbox.collision_mask = player_collision_mask
		charge_hitbox.monitoring = false
		charge_hitbox.body_entered.connect(_on_charge_hitbox_body_entered)
	_set_charge_hitbox_enabled(false)
	_update_animation()


func _physics_process(delta: float) -> void:
	# Cancelar perseguição/antecipação se o alvo sair da área de detecção.
	if current_state in [State.CHASE, State.WINDUP] and not _has_valid_target():
		target = null
		_change_state(State.IDLE)
		return

	match current_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, braking * delta)
			move_and_slide()
			if _has_valid_target():
				_change_state(State.CHASE)

		State.CHASE:
			var to_target := target.global_position - global_position
			if to_target.length() <= charge_trigger_distance:
				_change_state(State.WINDUP)
			else:
				velocity = to_target.normalized() * chase_speed
				_face_direction(to_target)
				move_and_slide()

		State.WINDUP:
			velocity = Vector2.ZERO
			state_time_left -= delta
			if state_time_left <= 0.0:
				_change_state(State.CHARGE)

		State.CHARGE:
			velocity = charge_direction * charge_speed
			move_and_slide()
			state_time_left -= delta
			if state_time_left <= 0.0 or get_slide_collision_count() > 0:
				_change_state(State.RECOVER)

		State.RECOVER:
			velocity = velocity.move_toward(Vector2.ZERO, braking * delta)
			move_and_slide()
			state_time_left -= delta
			if state_time_left <= 0.0:
				if _has_valid_target():
					_change_state(State.CHASE)
				else:
					target = null
					_change_state(State.IDLE)

		State.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, braking * delta)
			move_and_slide()
			state_time_left -= delta
			if state_time_left <= 0.0:
				_change_state(State.CHASE if _has_valid_target() else State.IDLE)

		State.DEFEATED:
			velocity = Vector2.ZERO

	_update_animation()


func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO) -> void:
	if amount <= 0 or current_state == State.DEFEATED:
		return

	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	if health == 0:
		_change_state(State.DEFEATED)
		return

	var knockback := global_position - source_position
	if knockback.length_squared() > 0.001:
		velocity = knockback.normalized() * stagger_knockback
	_change_state(State.STAGGER)


func get_state_name() -> String:
	return STATE_NAMES[current_state]


func _change_state(next_state: State) -> void:
	if current_state == State.DEFEATED or current_state == next_state:
		return

	var previous_state := current_state
	current_state = next_state
	state_changed.emit(previous_state, current_state)
	if next_state != State.CHARGE:
		_set_charge_hitbox_enabled(false)

	match next_state:
		State.IDLE, State.CHASE:
			state_time_left = 0.0
		State.WINDUP:
			state_time_left = windup_seconds
			velocity = Vector2.ZERO
			if _has_valid_target():
				charge_direction = (target.global_position - global_position).normalized()
			if charge_direction.length_squared() < 0.001:
				charge_direction = Vector2.RIGHT
			_face_direction(charge_direction)
		State.CHARGE:
			state_time_left = charge_seconds
			hit_already_this_charge = false
			if charge_hitbox != null:
				charge_hitbox.position = charge_direction * hitbox_forward_offset
			_set_charge_hitbox_enabled(true)
		State.RECOVER:
			state_time_left = recover_seconds
		State.STAGGER:
			state_time_left = stagger_seconds
		State.DEFEATED:
			velocity = Vector2.ZERO
			if detection_area != null:
				detection_area.set_deferred("monitoring", false)
			if body_shape != null:
				body_shape.set_deferred("disabled", true)
			set_deferred("collision_layer", 0)
			set_deferred("collision_mask", 0)
			defeated.emit(self)


func _on_detection_body_entered(body: Node2D) -> void:
	if not (body is CharacterBody2D) or not body.is_in_group(player_group):
		return
	target = body as CharacterBody2D
	target_in_range = true
	if current_state == State.IDLE:
		_change_state(State.CHASE)


func _on_detection_body_exited(body: Node2D) -> void:
	if body != target:
		return
	target_in_range = false
	if current_state in [State.IDLE, State.CHASE, State.WINDUP]:
		target = null
		if current_state != State.IDLE:
			_change_state(State.IDLE)


func _on_charge_hitbox_body_entered(body: Node2D) -> void:
	if current_state != State.CHARGE or hit_already_this_charge:
		return
	if body.is_in_group(player_group):
		hit_already_this_charge = true
		attack_requested.emit(body, charge_damage)


func _set_charge_hitbox_enabled(enabled: bool) -> void:
	if charge_hitbox != null:
		# A propriedade é diferida para evitar alterar monitoring durante a consulta física.
		charge_hitbox.set_deferred("monitoring", enabled)


func _has_valid_target() -> bool:
	return target_in_range and is_instance_valid(target) and not target.is_queued_for_deletion()


func _face_direction(direction: Vector2) -> void:
	if direction.length_squared() > 0.001:
		facing_direction = direction.normalized()


func _update_animation() -> void:
	if animation_sprite == null or animation_sprite.sprite_frames == null:
		return

	var prefix := "idle"
	var suffix := _direction_suffix()
	match current_state:
		State.IDLE:
			prefix = "idle"
		State.CHASE:
			prefix = "trot"
		State.WINDUP:
			prefix = "windup"
		State.CHARGE:
			prefix = "charge"
		State.RECOVER:
			prefix = "recover"
		State.STAGGER:
			prefix = "hit"
			suffix = ""
		State.DEFEATED:
			prefix = "vanish"
			suffix = ""

	var clip := StringName(prefix if suffix.is_empty() else "%s_%s" % [prefix, suffix])
	var frames: SpriteFrames = animation_sprite.sprite_frames
	if frames.has_animation(clip) and animation_sprite.animation != clip:
		animation_sprite.play(clip)
	elif prefix in ["windup", "recover"]:
		var fallback := StringName("idle_%s" % _direction_suffix())
		if frames.has_animation(fallback) and animation_sprite.animation != fallback:
			animation_sprite.play(fallback)


func _direction_suffix() -> String:
	if absf(facing_direction.x) > absf(facing_direction.y):
		if animation_sprite != null:
			animation_sprite.flip_h = facing_direction.x < 0.0
		return "side"
	if animation_sprite != null:
		animation_sprite.flip_h = false
	return "up" if facing_direction.y < 0.0 else "down"
