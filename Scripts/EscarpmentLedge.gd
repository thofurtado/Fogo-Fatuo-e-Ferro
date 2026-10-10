extends Node2D
class_name EscarpmentLedge

@export var ledge_width: float = 80.0
@export var ledge_height: float = 24.0
@export var drop_distance: float = 46.0
@export var penalty_hp: int = 3
@export var penalty_affinity: int = 5

@onready var solid_body = $StaticBody2D
@onready var solid_shape = $StaticBody2D/CollisionShape2D
@onready var drop_area = $DropTriggerArea
@onready var drop_shape = $DropTriggerArea/CollisionShape2D

signal player_dropped(ledge)

func _ready():
	_setup_shapes()
	if drop_area:
		drop_area.body_entered.connect(_on_drop_area_body_entered)

func _setup_shapes():
	if solid_shape and solid_shape.shape is RectangleShape2D:
		solid_shape.shape = solid_shape.shape.duplicate()
		var rect_shape = solid_shape.shape as RectangleShape2D
		rect_shape.size = Vector2(ledge_width, 16.0)
		solid_body.position = Vector2(0, 6)
		
	if drop_shape and drop_shape.shape is RectangleShape2D:
		drop_shape.shape = drop_shape.shape.duplicate()
		var trigger_shape = drop_shape.shape as RectangleShape2D
		trigger_shape.size = Vector2(max(10.0, ledge_width - 6.0), 12.0)
		drop_area.position = Vector2(0, -8)

func _on_drop_area_body_entered(body):
	if body is TropeiroPlayer and not body.is_falling_ledge:
		# Só ativa a queda se o jogador estiver descendo (acima da borda da escarpa)
		if body.global_position.y < global_position.y + 6.0:
			_execute_drop(body)

func _execute_drop(player: TropeiroPlayer):
	player_dropped.emit(self)
	var target_y = player.global_position.y + drop_distance
	player.drop_down_ledge(target_y, func():
		_apply_penalty()
	)

func _apply_penalty():
	var gm = get_node_or_null("/root/GameManager")
	if gm and "current_archetype" in gm:
		var arch = gm.current_archetype
		if arch and arch.has("vida_atual"):
			arch["vida_atual"] = max(1, arch["vida_atual"] - penalty_hp)
	
	var parent_scene = get_tree().current_scene
	if parent_scene and parent_scene.has_method("on_player_fell_ledge"):
		parent_scene.on_player_fell_ledge(penalty_hp, penalty_affinity)
