extends Node2D

@onready var player: TropeiroTilemapController = $YSortWorld/Tropeiro
@onready var mula: MulaSemCabecaController = $YSortWorld/MulaSemCabeca
@onready var combat_system: CombatSystem = $CombatSystem
@onready var y_sort_world: Node2D = $YSortWorld
@onready var windup_audio: AudioStreamPlayer2D = $YSortWorld/Tropeiro/WindupAudio
@onready var hit_audio: AudioStreamPlayer2D = $YSortWorld/HitAudio
@onready var player_health_label: Label = $UILayer/HUD/MarginContainer/VBoxContainer/PlayerHealth
@onready var mula_health_label: Label = $UILayer/HUD/MarginContainer/VBoxContainer/MulaHealth
@onready var mula_state_label: Label = $UILayer/HUD/MarginContainer/VBoxContainer/MulaState
@onready var event_label: Label = $UILayer/HUD/MarginContainer/VBoxContainer/Event


func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	player.attack_windup_started.connect(_on_player_attack_windup_started)
	player.attack_window_started.connect(_on_player_attack_window_started)
	mula.health_changed.connect(_on_mula_health_changed)
	mula.state_changed.connect(_on_mula_state_changed)
	mula.defeated.connect(_on_mula_defeated)
	combat_system.attack_applied.connect(_on_attack_applied)
	combat_system.attack_rejected.connect(_on_attack_rejected)
	_refresh_hud()
	_set_event("Aproxime-se da Mula; J ataca após um breve windup.")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()


func _refresh_hud() -> void:
	_on_player_health_changed(player.current_health, player.max_health)
	_on_mula_health_changed(mula.health, mula.max_health)
	_on_mula_state_changed(mula.current_state, mula.current_state)


func _on_player_health_changed(current: int, maximum: int) -> void:
	player_health_label.text = "Tropeiro — Vida: %d / %d" % [current, maximum]


func _on_mula_health_changed(current: int, maximum: int) -> void:
	mula_health_label.text = "Mula sem Cabeça — Vida: %d / %d" % [current, maximum]


func _on_mula_state_changed(_previous_state: int, _new_state: int) -> void:
	mula_state_label.text = "Estado da Mula: %s" % mula.get_state_name()


func _on_player_attack_windup_started(direction: Vector2) -> void:
	windup_audio.play()
	_set_event("Tropeiro prepara o golpe…")
	var marker := PackedVector2Array([
		Vector2(0, -7), Vector2(21, -7), Vector2(31, 0),
		Vector2(21, 7), Vector2(0, 7)
	])
	_spawn_direction_fx(direction, Color(1.0, 0.74, 0.24, 0.95), marker, player.attack_windup, Vector2(0.35, 0.72), Vector2.ONE)


func _on_player_attack_window_started(direction: Vector2) -> void:
	var slash := PackedVector2Array([
		Vector2(-5, -15), Vector2(15, -12), Vector2(29, 0),
		Vector2(15, 12), Vector2(-5, 15), Vector2(7, 0)
	])
	_spawn_direction_fx(direction, Color(1.0, 0.88, 0.49, 0.9), slash, 0.12, Vector2(0.55, 0.75), Vector2(1.15, 1.0))
	_set_event("Golpe do Tropeiro!")


func _spawn_direction_fx(direction: Vector2, tint: Color, points: PackedVector2Array, duration: float, start_scale: Vector2, end_scale: Vector2) -> void:
	var fx := Polygon2D.new()
	fx.polygon = points
	fx.color = tint
	fx.position = y_sort_world.to_local(player.global_position + direction * 23.0)
	fx.rotation = direction.angle()
	fx.scale = start_scale
	fx.z_index = 20
	y_sort_world.add_child(fx)

	var tween := create_tween()
	tween.set_parallel(true)
	var safe_duration := maxf(duration, 0.06)
	tween.tween_property(fx, "scale", end_scale, safe_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(fx, "modulate", Color(1, 1, 1, 0), safe_duration)
	tween.chain().tween_callback(Callable(fx, "queue_free"))


func _on_attack_applied(attacker: Node, target: Node2D, damage: int) -> void:
	var attacker_name := "Tropeiro" if attacker == player else "Mula sem Cabeça"
	var target_name := "Mula sem Cabeça" if target == mula else "Tropeiro"
	_set_event("%s acertou %s: %d de dano." % [attacker_name, target_name, damage])
	if attacker == player:
		hit_audio.global_position = target.global_position
		hit_audio.play()
		_spawn_hit_spark(target.global_position)


func _spawn_hit_spark(global_position: Vector2) -> void:
	var spark := Polygon2D.new()
	spark.polygon = PackedVector2Array([
		Vector2(0, -13), Vector2(4, -5), Vector2(12, -9), Vector2(7, -1),
		Vector2(13, 5), Vector2(4, 5), Vector2(0, 14), Vector2(-4, 5),
		Vector2(-13, 9), Vector2(-7, 1), Vector2(-12, -6), Vector2(-3, -5)
	])
	spark.color = Color(1.0, 0.83, 0.35, 1.0)
	spark.position = y_sort_world.to_local(global_position + Vector2(0, -17))
	spark.scale = Vector2(0.45, 0.45)
	spark.z_index = 24
	y_sort_world.add_child(spark)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(spark, "scale", Vector2(1.45, 1.45), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(spark, "modulate", Color(1, 1, 1, 0), 0.14)
	tween.chain().tween_callback(Callable(spark, "queue_free"))


func _on_attack_rejected(_attacker: Node, _target: Node2D, reason: StringName) -> void:
	_set_event("Ataque recusado: %s." % String(reason))


func _on_player_died() -> void:
	_set_event("O Tropeiro foi derrotado. Pressione R para reiniciar.")


func _on_mula_defeated(_enemy: Node2D) -> void:
	_set_event("A Mula sem Cabeça foi derrotada. Pressione R para reiniciar.")


func _set_event(message: String) -> void:
	event_label.text = message
