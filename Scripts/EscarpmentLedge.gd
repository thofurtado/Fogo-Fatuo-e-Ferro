extends Node2D
class_name EscarpmentLedge

@export var ledge_width: float = 80.0:
	set(val):
		ledge_width = val
		_setup_shapes()

@export var ledge_height: float = 24.0:
	set(val):
		ledge_height = val
		_setup_shapes()

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
		drop_area.collision_mask = 0xFFFFFFFF
		if not drop_area.body_entered.is_connected(_on_drop_area_body_entered):
			drop_area.body_entered.connect(_on_drop_area_body_entered)

func _setup_shapes():
	queue_redraw()
	if not is_inside_tree():
		return
	if not solid_shape:
		solid_shape = get_node_or_null("StaticBody2D/CollisionShape2D")
	if not drop_shape:
		drop_shape = get_node_or_null("DropTriggerArea/CollisionShape2D")
	if not solid_body:
		solid_body = get_node_or_null("StaticBody2D")
	if not drop_area:
		drop_area = get_node_or_null("DropTriggerArea")

	if solid_shape and solid_shape.shape is RectangleShape2D:
		solid_shape.shape = solid_shape.shape.duplicate()
		var rect_shape = solid_shape.shape as RectangleShape2D
		var wall_h = max(16.0, ledge_height - 16.0)
		rect_shape.size = Vector2(ledge_width, wall_h)
		if solid_body:
			solid_body.position = Vector2(0, (wall_h / 2.0) - 2.0)
		
	if drop_shape and drop_shape.shape is RectangleShape2D:
		drop_shape.shape = drop_shape.shape.duplicate()
		var trigger_shape = drop_shape.shape as RectangleShape2D
		trigger_shape.size = Vector2(max(10.0, ledge_width), 16.0)
		if drop_area:
			drop_area.position = Vector2(0, -8)

# A low, uneven earth/stone lip marks the drop without exposing editor glyphs.
func _draw():
	var half_width = ledge_width * 0.5
	var bottom = clampf(ledge_height * 0.35, 6.0, 12.0)
	var outline = PackedVector2Array([
		Vector2(-half_width, -1), Vector2(-half_width + 7, -5),
		Vector2(half_width - 5, -4), Vector2(half_width, 0),
		Vector2(half_width - 3, bottom - 1), Vector2(-half_width + 2, bottom)
	])
	draw_colored_polygon(outline, Color(0.55, 0.42, 0.28))
	draw_line(Vector2(-half_width + 7, -4), Vector2(half_width - 5, -3), Color(0.42, 0.47, 0.25), 2)
	var x = -half_width + 17
	while x < half_width - 7:
		draw_line(Vector2(x, 1), Vector2(x + 6, bottom - 2), Color(0.61, 0.49, 0.32), 2)
		x += 31

func _on_drop_area_body_entered(body):
	# Apenas corpos móveis (Player, Mula, criaturas, seguidores, NPCs)
	if not (body is CharacterBody2D or body is RigidBody2D or body.has_method("drop_down_ledge")):
		return
		
	# Evita reativar se já estiver executando salto
	if ("is_falling_ledge" in body and body.is_falling_ledge) or (body.has_meta("is_falling_ledge") and body.get_meta("is_falling_ledge")):
		return
		
	# Só ativa o salto se a criatura estiver acima da escarpa descendo em direção a ela
	if body.global_position.y < global_position.y + 8.0:
		_process_drop(body)

func _process_drop(body: Node2D):
	var target_y = body.global_position.y + drop_distance
	
	if body is TropeiroPlayer:
		player_dropped.emit(self)
		body.drop_down_ledge(target_y, func():
			_apply_penalty()
		)
	elif body.has_method("drop_down_ledge"):
		# Qualquer criatura com rotina própria (ex: MulaBonita ou futuros companheiros)
		body.drop_down_ledge(target_y)
	else:
		# Salto genérico para qualquer criatura ou NPC sem método customizado
		_execute_generic_creature_drop(body, target_y)

func _execute_generic_creature_drop(body: Node2D, target_y: float):
	if "is_falling_ledge" in body:
		body.is_falling_ledge = true
	body.set_meta("is_falling_ledge", true)
	
	if "velocity" in body:
		body.velocity = Vector2.ZERO
		
	# Procura representação visual (sprite) para realizar o arco no ar
	var sprite_node: Node2D = null
	for child in body.get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			sprite_node = child
			break
			
	if sprite_node:
		var orig_y = sprite_node.position.y
		var hop = create_tween()
		hop.tween_property(sprite_node, "position:y", orig_y - 14.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		hop.tween_property(sprite_node, "position:y", orig_y, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
	var move = create_tween()
	move.tween_property(body, "global_position:y", target_y, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await move.finished
	
	if "is_falling_ledge" in body:
		body.is_falling_ledge = false
	body.set_meta("is_falling_ledge", false)

func _apply_penalty():
	var gm = get_node_or_null("/root/GameManager")
	if gm and "current_archetype" in gm:
		var arch = gm.current_archetype
		if arch and arch.has("vida_atual"):
			arch["vida_atual"] = max(1, arch["vida_atual"] - penalty_hp)
	
	var parent_scene = get_tree().current_scene
	if parent_scene and parent_scene.has_method("on_player_fell_ledge"):
		parent_scene.on_player_fell_ledge(penalty_hp, penalty_affinity)
