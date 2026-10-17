extends Node2D
class_name CombatFeedback

@export var player_path: NodePath
@export var enemy_path: NodePath
@export var combat_system_path: NodePath
@export var world_layer_path: NodePath

@onready var windup_audio: AudioStreamPlayer2D = get_node_or_null("WindupAudio") as AudioStreamPlayer2D
@onready var hit_audio: AudioStreamPlayer2D = get_node_or_null("HitAudio") as AudioStreamPlayer2D

var player: Node2D
var enemy: Node2D
var combat_system: Node
var world_layer: Node2D
var _pixel_texture: Texture2D


func _ready() -> void:
	player = get_node_or_null(player_path) as Node2D
	enemy = get_node_or_null(enemy_path) as Node2D
	combat_system = get_node_or_null(combat_system_path)
	world_layer = get_node_or_null(world_layer_path) as Node2D
	_pixel_texture = _make_pixel_texture()

	_connect_signal(player, &"attack_windup_started", &"_on_player_attack_windup_started")
	_connect_signal(player, &"attack_window_started", &"_on_player_attack_window_started")
	_connect_signal(combat_system, &"attack_applied", &"_on_attack_applied")
	_connect_signal(enemy, &"state_changed", &"_on_enemy_state_changed")
	_connect_signal(enemy, &"defeated", &"_on_enemy_defeated")


func _connect_signal(source: Node, signal_name: StringName, method_name: StringName) -> void:
	if source == null or not source.has_signal(signal_name):
		return
	var callback := Callable(self, method_name)
	if not source.is_connected(signal_name, callback):
		source.connect(signal_name, callback)


func _on_player_attack_windup_started(direction: Vector2) -> void:
	if not is_instance_valid(player):
		return
	_play_audio(windup_audio, player.global_position)
	_emit_pixel_burst(
		player.global_position + direction * 22.0,
		direction,
		Color(1.0, 0.68, 0.18, 1.0),
		8,
		0.24,
		18.0,
		38.0,
		38.0
	)


func _on_player_attack_window_started(direction: Vector2) -> void:
	if not is_instance_valid(player):
		return
	_spawn_slash(player.global_position + direction * 28.0, direction)


func _on_attack_applied(attacker: Node, target: Node2D, damage: int) -> void:
	if not is_instance_valid(target):
		return
	var tint := Color(1.0, 0.82, 0.32, 1.0)
	if target == player:
		tint = Color(0.36, 0.78, 1.0, 1.0)
		_play_audio(hit_audio, target.global_position)
	elif attacker == player:
		_play_audio(hit_audio, target.global_position)
	_emit_pixel_burst(target.global_position + Vector2(0.0, -14.0), Vector2.UP, tint, 16, 0.30, 28.0, 72.0, 180.0)


func _on_enemy_state_changed(_previous_state: int, new_state: int) -> void:
	if not is_instance_valid(enemy) or not enemy.has_method("get_state_name"):
		return
	if String(enemy.call("get_state_name")) != "WINDUP":
		return
	var direction: Vector2 = enemy.get("facing_direction")
	if direction.length_squared() < 0.001:
		direction = Vector2.DOWN
	_emit_pixel_burst(
		enemy.global_position + Vector2(0.0, -28.0),
		direction,
		Color(0.18, 0.78, 1.0, 1.0),
		12,
		0.42,
		14.0,
		34.0,
		130.0
	)


func _on_enemy_defeated(_defeated_enemy: Node2D) -> void:
	if is_instance_valid(enemy):
		_emit_pixel_burst(enemy.global_position + Vector2(0.0, -25.0), Vector2.UP, Color(0.27, 0.83, 1.0, 1.0), 24, 0.55, 32.0, 90.0, 180.0)


func _play_audio(audio: AudioStreamPlayer2D, at_position: Vector2) -> void:
	if audio == null or audio.stream == null:
		return
	audio.global_position = at_position
	audio.play()


func _spawn_slash(at_position: Vector2, direction: Vector2) -> void:
	var slash := Polygon2D.new()
	slash.name = "TemporarySlashFX"
	slash.polygon = PackedVector2Array([
		Vector2(-5.0, -13.0), Vector2(14.0, -11.0), Vector2(29.0, 0.0),
		Vector2(14.0, 11.0), Vector2(-5.0, 13.0), Vector2(7.0, 0.0)
	])
	slash.color = Color(1.0, 0.88, 0.48, 0.96)
	slash.rotation = direction.angle()
	slash.scale = Vector2(0.55, 0.70)
	slash.z_index = 20
	_add_world_effect(slash, at_position)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(slash, "scale", Vector2(1.2, 1.0), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(slash, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.14)
	tween.chain().tween_callback(Callable(slash, "queue_free"))


func _emit_pixel_burst(at_position: Vector2, direction: Vector2, tint: Color, particle_count: int, duration: float, speed_min: float, speed_max: float, spread_degrees: float) -> void:
	var particles := CPUParticles2D.new()
	particles.name = "TemporaryCombatParticles"
	particles.texture = _pixel_texture
	particles.amount = particle_count
	particles.lifetime = duration
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = false
	particles.direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.UP
	particles.spread = spread_degrees
	particles.gravity = Vector2(0.0, 46.0)
	particles.initial_velocity_min = speed_min
	particles.initial_velocity_max = speed_max
	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 1.8
	particles.color = tint
	particles.z_index = 18
	_add_world_effect(particles, at_position)
	particles.finished.connect(particles.queue_free, CONNECT_ONE_SHOT)
	particles.emitting = true


func _add_world_effect(effect: Node2D, at_position: Vector2) -> void:
	var parent_layer := world_layer if is_instance_valid(world_layer) else self
	parent_layer.add_child(effect)
	effect.global_position = at_position


func _make_pixel_texture() -> Texture2D:
	var image := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)
