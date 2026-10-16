extends Node
class_name CombatTestLogger

@export var player_path: NodePath
@export var enemy_path: NodePath
@export var combat_system_path: NodePath
@export var log_directory: String = "user://combat_logs"
@export var session_tag: String = "subida_serra"
@export_range(0.1, 10.0, 0.1) var sample_interval_seconds: float = 1.0
@export var start_on_ready: bool = true

var player: Node
var enemy: Node
var combat_system: Node
var log_file_path: String = ""
var session_id: String = ""
var _file: FileAccess
var _active: bool = false
var _elapsed_seconds: float = 0.0
var _sample_timer: float = 0.0
var _sample_count: int = 0
var _fps_total: float = 0.0
var _fps_min: float = INF
var _process_ms_total: float = 0.0
var _physics_ms_total: float = 0.0
var _last_fps: float = 0.0
var _last_process_ms: float = 0.0
var _last_physics_ms: float = 0.0


func _ready() -> void:
	player = get_node_or_null(player_path)
	enemy = get_node_or_null(enemy_path)
	combat_system = get_node_or_null(combat_system_path)
	_connect_combat_signals()
	set_process(false)
	if start_on_ready:
		start_logging()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		if _active:
			stop_logging("F8")
		else:
			start_logging()


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed_seconds += delta
	_sample_timer += delta
	if _sample_timer >= sample_interval_seconds:
		_sample_timer = 0.0
		_sample_performance()


func start_logging() -> bool:
	if _active:
		return true
	if not is_instance_valid(player):
		push_warning("CombatTestLogger: não encontrei o jogador no caminho configurado.")
		return false

	var absolute_dir := ProjectSettings.globalize_path(log_directory)
	var dir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if dir_error != OK and not DirAccess.dir_exists_absolute(absolute_dir):
		push_error("CombatTestLogger: não foi possível criar a pasta %s." % absolute_dir)
		return false

	var timestamp := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	session_id = "%s_%d" % [timestamp, Time.get_ticks_usec()]
	log_file_path = log_directory.path_join("combat_%s_%s.csv" % [session_tag, session_id])
	_file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if _file == null:
		push_error("CombatTestLogger: falha ao abrir o arquivo de log (erro %d)." % FileAccess.get_open_error())
		return false

	_elapsed_seconds = 0.0
	_sample_timer = 0.0
	_sample_count = 0
	_fps_total = 0.0
	_fps_min = INF
	_process_ms_total = 0.0
	_physics_ms_total = 0.0
	_last_fps = 0.0
	_last_process_ms = 0.0
	_last_physics_ms = 0.0
	_file.store_csv_line(PackedStringArray([
		"session_id", "elapsed_s", "event", "actor", "target", "value",
		"player_hp", "enemy_hp", "enemy_state", "fps", "process_ms", "physics_ms", "note"
	]))
	_active = true
	set_process(true)
	_write_event("session_start", "", "", 0.0, "tag=%s" % session_tag)
	_write_event("balance_config", "", "", 0.0, _balance_config_json())
	print("CombatTestLogger: registrando em %s (F8 alterna gravação)." % ProjectSettings.globalize_path(log_file_path))
	return true


func stop_logging(reason: String = "manual") -> void:
	if not _active or _file == null:
		return
	_write_event("session_end", "", "", _elapsed_seconds, _build_summary(reason))
	_file.flush()
	_file.close()
	_file = null
	_active = false
	set_process(false)
	print("CombatTestLogger: sessão encerrada em %s." % ProjectSettings.globalize_path(log_file_path))


func is_logging() -> bool:
	return _active


func get_log_file_path() -> String:
	return log_file_path


func _exit_tree() -> void:
	stop_logging("scene_exit")


func _connect_combat_signals() -> void:
	_connect_signal(player, &"attack_windup_started", &"_on_player_windup")
	_connect_signal(player, &"attack_window_started", &"_on_player_attack_window")
	_connect_signal(player, &"health_changed", &"_on_player_health_changed")
	_connect_signal(player, &"died", &"_on_player_died")
	_connect_signal(enemy, &"health_changed", &"_on_enemy_health_changed")
	_connect_signal(enemy, &"state_changed", &"_on_enemy_state_changed")
	_connect_signal(enemy, &"defeated", &"_on_enemy_defeated")
	_connect_signal(combat_system, &"attack_applied", &"_on_attack_applied")
	_connect_signal(combat_system, &"attack_rejected", &"_on_attack_rejected")


func _connect_signal(source: Node, signal_name: StringName, method_name: StringName) -> void:
	if source == null or not source.has_signal(signal_name):
		return
	var callback := Callable(self, method_name)
	if not source.is_connected(signal_name, callback):
		source.connect(signal_name, callback)


func _sample_performance() -> void:
	_last_fps = float(Performance.get_monitor(Performance.TIME_FPS))
	_last_process_ms = float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0
	_last_physics_ms = float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) * 1000.0
	_sample_count += 1
	_fps_total += _last_fps
	_fps_min = minf(_fps_min, _last_fps)
	_process_ms_total += _last_process_ms
	_physics_ms_total += _last_physics_ms
	_write_event("performance_sample", "", "", _last_fps, "one_second_sample")


func _write_event(event_name: String, actor_name: String, target_name: String, value: float, note: String) -> void:
	if not _active or _file == null:
		return
	_file.store_csv_line(PackedStringArray([
		session_id,
		"%.3f" % _elapsed_seconds,
		event_name,
		actor_name,
		target_name,
		"%.3f" % value,
		str(_read_int(player, &"current_health", -1)),
		str(_read_int(enemy, &"health", -1)),
		_get_enemy_state(),
		"%.2f" % _last_fps,
		"%.3f" % _last_process_ms,
		"%.3f" % _last_physics_ms,
		note
	]))
	_file.flush()


func _on_player_windup(direction: Vector2) -> void:
	var windup := float(_read_property(player, &"attack_windup", 0.0))
	_write_event("player_windup", _node_name(player), "", windup, "dir=%.2f,%.2f" % [direction.x, direction.y])


func _on_player_attack_window(direction: Vector2) -> void:
	_write_event("player_attack_window", _node_name(player), "", 0.0, "dir=%.2f,%.2f" % [direction.x, direction.y])


func _on_attack_applied(attacker: Node, target: Node2D, damage: int) -> void:
	_write_event("attack_applied", _node_name(attacker), _node_name(target), float(damage), "")


func _on_attack_rejected(attacker: Node, target: Node2D, reason: StringName) -> void:
	_write_event("attack_rejected", _node_name(attacker), _node_name(target), 0.0, String(reason))


func _on_player_health_changed(current: int, maximum: int) -> void:
	_write_event("player_health", _node_name(player), "", float(current), "max=%d" % maximum)


func _on_enemy_health_changed(current: int, maximum: int) -> void:
	_write_event("enemy_health", _node_name(enemy), "", float(current), "max=%d" % maximum)


func _on_enemy_state_changed(previous_state: int, new_state: int) -> void:
	_write_event("enemy_state", _node_name(enemy), "", float(new_state), "previous=%d; current=%s" % [previous_state, _get_enemy_state()])


func _on_player_died() -> void:
	_write_event("player_defeated", _node_name(player), "", 0.0, "")


func _on_enemy_defeated(_defeated_enemy: Node2D) -> void:
	_write_event("enemy_defeated", _node_name(enemy), "", 0.0, "")


func _balance_config_json() -> String:
	if not is_instance_valid(enemy):
		return "enemy_config_unavailable"
	var config := {
		"enemy_hp": _read_int(enemy, &"max_health", -1),
		"chase_speed": _read_property(enemy, &"chase_speed", -1.0),
		"charge_speed": _read_property(enemy, &"charge_speed", -1.0),
		"charge_trigger_distance": _read_property(enemy, &"charge_trigger_distance", -1.0),
		"windup_seconds": _read_property(enemy, &"windup_seconds", -1.0),
		"charge_seconds": _read_property(enemy, &"charge_seconds", -1.0),
		"recover_seconds": _read_property(enemy, &"recover_seconds", -1.0),
		"charge_damage": _read_property(enemy, &"charge_damage", -1),
		"player_damage": _read_property(player, &"attack_damage", -1),
		"player_windup_seconds": _read_property(player, &"attack_windup", -1.0)
	}
	return JSON.stringify(config)


func _build_summary(reason: String) -> String:
	if _sample_count == 0:
		return "reason=%s;samples=0" % reason
	var mean_fps := _fps_total / float(_sample_count)
	var mean_process_ms := _process_ms_total / float(_sample_count)
	var mean_physics_ms := _physics_ms_total / float(_sample_count)
	return "reason=%s;samples=%d;mean_fps=%.2f;min_fps=%.2f;mean_process_ms=%.3f;mean_physics_ms=%.3f" % [
		reason,
		_sample_count,
		mean_fps,
		_fps_min,
		mean_process_ms,
		mean_physics_ms
	]


func _get_enemy_state() -> String:
	if is_instance_valid(enemy) and enemy.has_method("get_state_name"):
		return String(enemy.call("get_state_name"))
	return ""


func _node_name(node: Object) -> String:
	if is_instance_valid(node) and node is Node:
		return String((node as Node).name)
	return ""


func _read_int(object: Object, property: StringName, fallback: int) -> int:
	return int(_read_property(object, property, fallback))


func _read_property(object: Object, property: StringName, fallback: Variant) -> Variant:
	if not is_instance_valid(object):
		return fallback
	var value: Variant = object.get(property)
	if value == null:
		return fallback
	return value
