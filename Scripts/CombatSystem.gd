extends Node
class_name CombatSystem

signal attack_applied(attacker: Node, target: Node2D, damage: int)
signal attack_rejected(attacker: Node, target: Node2D, reason: StringName)

@export var player_group: StringName = &"player"
@export var enemy_group: StringName = &"enemy"

var _registered_attackers: Dictionary = {}


func _ready() -> void:
	var tree := get_tree()
	if not tree.node_added.is_connected(_on_node_added):
		tree.node_added.connect(_on_node_added)
	_register_existing_group(player_group)
	_register_existing_group(enemy_group)


func _register_existing_group(group_name: StringName) -> void:
	for actor in get_tree().get_nodes_in_group(group_name):
		_register_attacker(actor)


func _on_node_added(node: Node) -> void:
	# Os controladores entram nos grupos em _ready(); a chamada diferida
	# registra-os quando a inicialização do novo nó já terminou.
	call_deferred("_register_if_attacker", node)


func _register_if_attacker(actor: Node) -> void:
	if not is_instance_valid(actor):
		return
	if actor.is_in_group(player_group) or actor.is_in_group(enemy_group):
		_register_attacker(actor)


func _register_attacker(actor: Node) -> void:
	if actor == self or not actor.has_signal("attack_requested"):
		return
	var instance_id: int = actor.get_instance_id()
	if _registered_attackers.has(instance_id):
		return
	var callback := Callable(self, "_on_attack_requested").bind(actor)
	if not actor.is_connected("attack_requested", callback):
		var error: int = actor.connect("attack_requested", callback)
		if error != OK:
			push_warning("CombatSystem não conseguiu conectar attack_requested de %s." % actor.name)
			return
	_registered_attackers[instance_id] = actor
	actor.tree_exited.connect(_forget_attacker.bind(instance_id), CONNECT_ONE_SHOT)


func _forget_attacker(instance_id: int) -> void:
	_registered_attackers.erase(instance_id)


func _on_attack_requested(target: Node2D, damage: int, attacker: Node) -> void:
	if not is_instance_valid(attacker) or not is_instance_valid(target) or target.is_queued_for_deletion():
		return
	if damage <= 0 or target == attacker or _is_friendly_fire(attacker, target):
		attack_rejected.emit(attacker, target, &"invalid_or_friendly_target")
		return
	if not target.has_method("take_damage"):
		attack_rejected.emit(attacker, target, &"target_has_no_take_damage")
		return

	var source_position := Vector2.ZERO
	if attacker is Node2D:
		source_position = (attacker as Node2D).global_position
	target.call("take_damage", damage, source_position)
	attack_applied.emit(attacker, target, damage)


func _is_friendly_fire(attacker: Node, target: Node2D) -> bool:
	if attacker.is_in_group(player_group):
		return target.is_in_group(player_group)
	if attacker.is_in_group(enemy_group):
		return target.is_in_group(enemy_group)
	return false
