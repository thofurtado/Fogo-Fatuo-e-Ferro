extends CharacterBody2D
class_name TropeiroTilemapController

@export_range(1.0, 500.0, 1.0) var move_speed: float = 160.0
@export_range(1.0, 3000.0, 1.0) var acceleration: float = 1400.0
@export_range(1.0, 4000.0, 1.0) var braking: float = 1800.0
@export var movement_enabled: bool = true

@onready var animation_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var facing_direction: StringName = &"down"


func _ready() -> void:
	# Em top-down, toda colisão é tratada como obstáculo, não como piso.
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")


func _physics_process(delta: float) -> void:
	var direction := _read_direction()
	if not movement_enabled:
		direction = Vector2.ZERO

	if direction != Vector2.ZERO:
		_update_facing(direction)

	var target_velocity := direction * move_speed
	var rate := acceleration if direction != Vector2.ZERO else braking
	velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()
	_update_animation()


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO


func _read_direction() -> Vector2:
	# ui_* aceita as setas/controles configurados no Input Map; WASD preserva
	# o padrão já usado pelos controladores atuais do projeto.
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
	# Em diagonal, mantém a orientação do eixo dominante; em empate, mantém a anterior.
	if absf(direction.x) > absf(direction.y):
		facing_direction = &"right" if direction.x > 0.0 else &"left"
	elif absf(direction.y) > absf(direction.x):
		facing_direction = &"down" if direction.y > 0.0 else &"up"


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
