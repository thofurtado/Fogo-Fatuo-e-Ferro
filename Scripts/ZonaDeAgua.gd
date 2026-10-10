@tool
extends Area2D
class_name ZonaDeAgua

@export_category("Zona de Água e Correnteza")
@export var tamanho: Vector2 = Vector2(160, 64):
	set(val):
		tamanho = val
		_sincronizar_shape()
		queue_redraw()

@export_range(0.05, 0.95, 0.05) var fator_velocidade: float = 0.35:
	set(val):
		fator_velocidade = val

@export var afundar_pes_px: float = 3.5:
	set(val):
		afundar_pes_px = val

@export_group("Visual e Estilo")
@export var mostrar_visual_agua: bool = true:
	set(val):
		mostrar_visual_agua = val
		queue_redraw()

@export var cor_agua: Color = Color(0.18, 0.48, 0.72, 0.45):
	set(val):
		cor_agua = val
		queue_redraw()

@export var cor_borda: Color = Color(0.35, 0.75, 0.90, 0.65):
	set(val):
		cor_borda = val
		queue_redraw()

@export var desenhar_ondinhas: bool = true:
	set(val):
		desenhar_ondinhas = val
		queue_redraw()

@onready var col_shape_node: CollisionShape2D = $CollisionShape2D

func _ready():
	collision_mask = 0xFFFFFFFF
	collision_layer = 0
	_sincronizar_shape()
	
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(_delta):
	if Engine.is_editor_hint():
		if col_shape_node and col_shape_node.shape is RectangleShape2D:
			var shape_size = (col_shape_node.shape as RectangleShape2D).size
			if shape_size != tamanho:
				tamanho = shape_size
				queue_redraw()

func _sincronizar_shape():
	if not col_shape_node:
		col_shape_node = get_node_or_null("CollisionShape2D")
	if col_shape_node:
		if not col_shape_node.shape:
			col_shape_node.shape = RectangleShape2D.new()
		elif not col_shape_node.shape.is_local_to_scene():
			col_shape_node.shape = col_shape_node.shape.duplicate()
		(col_shape_node.shape as RectangleShape2D).size = tamanho

func _draw():
	if Engine.is_editor_hint() or mostrar_visual_agua:
		var half = tamanho / 2.0
		var rect = Rect2(-half, tamanho)
		
		# Fundo de água translúcido estilo gibi aquarela
		draw_rect(rect, cor_agua, true)
		# Borda de espuma / margem do rio
		draw_rect(rect, cor_borda, false, 1.5)
		
		if desenhar_ondinhas and tamanho.x >= 20.0 and tamanho.y >= 16.0:
			var wave_col = Color(cor_borda.r, cor_borda.g, cor_borda.b, cor_borda.a * 0.8)
			var num_waves = max(1, int(tamanho.x / 48.0))
			for i in range(num_waves):
				var wx = -half.x + (i + 0.5) * (tamanho.x / num_waves)
				var wy1 = -half.y + tamanho.y * 0.35
				var wy2 = -half.y + tamanho.y * 0.65
				draw_line(Vector2(wx - 10, wy1), Vector2(wx + 10, wy1), wave_col, 1.5)
				draw_line(Vector2(wx - 6, wy2), Vector2(wx + 6, wy2), wave_col, 1.5)

func _on_body_entered(body: Node2D):
	if body.has_method("enter_water_zone"):
		body.enter_water_zone(fator_velocidade, afundar_pes_px)
	elif "speed" in body:
		if not body.has_meta("original_speed"):
			body.set_meta("original_speed", body.speed)
		body.speed = body.get_meta("original_speed") * fator_velocidade

func _on_body_exited(body: Node2D):
	if body.has_method("exit_water_zone"):
		body.exit_water_zone()
	elif "speed" in body and body.has_meta("original_speed"):
		body.speed = body.get_meta("original_speed")
