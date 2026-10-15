extends Node2D

@onready var player: TropeiroTilemapController = $YSortWorld/Tropeiro
@onready var mula: MulaSemCabecaController = $YSortWorld/MulaSemCabeca
@onready var combat_system: CombatSystem = $CombatSystem
@onready var player_health_label: Label = $UILayer/HUD/MarginContainer/VBoxContainer/PlayerHealth
@onready var mula_health_label: Label = $UILayer/HUD/MarginContainer/VBoxContainer/MulaHealth
@onready var mula_state_label: Label = $UILayer/HUD/MarginContainer/VBoxContainer/MulaState
@onready var event_label: Label = $UILayer/HUD/MarginContainer/VBoxContainer/Event


func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	mula.health_changed.connect(_on_mula_health_changed)
	mula.state_changed.connect(_on_mula_state_changed)
	mula.defeated.connect(_on_mula_defeated)
	combat_system.attack_applied.connect(_on_attack_applied)
	combat_system.attack_rejected.connect(_on_attack_rejected)
	_refresh_hud()
	_set_event("Aproxime-se da Mula; pressione J para atacar.")


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


func _on_attack_applied(attacker: Node, target: Node2D, damage: int) -> void:
	var attacker_name := "Tropeiro" if attacker == player else "Mula sem Cabeça"
	var target_name := "Mula sem Cabeça" if target == mula else "Tropeiro"
	_set_event("%s acertou %s: %d de dano." % [attacker_name, target_name, damage])


func _on_attack_rejected(_attacker: Node, _target: Node2D, reason: StringName) -> void:
	_set_event("Ataque recusado: %s." % String(reason))


func _on_player_died() -> void:
	_set_event("O Tropeiro foi derrotado. Pressione R para reiniciar.")


func _on_mula_defeated(_enemy: Node2D) -> void:
	_set_event("A Mula sem Cabeça foi derrotada. Pressione R para reiniciar.")


func _set_event(message: String) -> void:
	event_label.text = message
