class_name DiceTray
extends Control

# ==============================================================================
# BANDEJA DE DADOS DINÂMICA (DICE TRAY 2D) - FOGO-FÁTUO & FERRO (1645)
# ==============================================================================
# Simula a rolagem física de D10s quicando pelas bordas de uma bandeja de jacarandá
# e couro curtido. Utiliza as regras do sistema Storyteller (Vampiro: A Máscara / BANDEIRA).
# ==============================================================================

signal roll_started
signal roll_completed(result_dict: Dictionary)

@export var die_size: Vector2 = Vector2(48, 48)
@export var tray_padding: float = 16.0
@export var roll_duration: float = 1.35

var is_rolling: bool = false
var roll_elapsed: float = 0.0
var scramble_timer: float = 0.0

var dice_nodes: Array[PanelContainer] = []
var dice_labels: Array[Label] = []
var dice_data: Array[Dictionary] = [] # {pos: Vector2, vel: Vector2, rot: float, rot_vel: float, target_val: int}

var current_result: Dictionary = {}

@onready var tray_background = $TrayBackground
@onready var dice_container = $DiceContainer
@onready var summary_label = $SummaryLabel
@onready var empty_hint_label = $EmptyHintLabel

func _ready():
	custom_minimum_size = Vector2(500, 200)
	if empty_hint_label:
		empty_hint_label.text = "Os 8 dados de osso repousam no copo de couro..."
	if summary_label:
		summary_label.text = ""

func setup_dice(count: int = 8):
	# Limpa dados anteriores
	for child in dice_container.get_children():
		child.queue_free()
	dice_nodes.clear()
	dice_labels.clear()
	dice_data.clear()
	
	# Cria os novos dados
	for i in range(count):
		var die = PanelContainer.new()
		die.custom_minimum_size = die_size
		die.size = die_size
		die.pivot_offset = die_size / 2.0
		die.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Estilo inicial rústico
		_apply_die_style(die, "neutral")
		
		var label = Label.new()
		label.text = "?"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.75))
		die.add_child(label)
		
		dice_container.add_child(die)
		dice_nodes.append(die)
		dice_labels.append(label)
		
		# Posição inicial alinhada
		var init_pos = _get_grid_position(i, count)
		die.position = init_pos
		
		dice_data.append({
			"pos": init_pos,
			"vel": Vector2.ZERO,
			"rot": 0.0,
			"rot_vel": 0.0,
			"target_val": 1
		})
	
	if empty_hint_label:
		empty_hint_label.visible = false

func roll_dice(pool_size: int = 8, difficulty: int = 6):
	if is_rolling:
		return
	
	setup_dice(pool_size)
	
	# Rola matematicamente usando o DiceRoller oficial
	current_result = DiceRoller.rolar_teste(pool_size, difficulty)
	var final_values: Array = current_result["dados_rolados"]
	
	is_rolling = true
	roll_elapsed = 0.0
	scramble_timer = 0.0
	if summary_label:
		summary_label.text = "🎲 Rolando dados de osso na bandeja..."
	
	var tray_w = size.x if size.x > 0 else 520.0
	var tray_h = size.y if size.y > 0 else 200.0
	
	# Dá impulso explosivo inicial para cada dado quicar
	for i in range(pool_size):
		var target_num = final_values[i] if i < final_values.size() else (randi() % 10 + 1)
		
		var rx = randf_range(tray_padding + 20, tray_w - tray_padding - die_size.x - 20)
		var ry = randf_range(tray_padding + 20, tray_h - tray_padding - die_size.y - 40)
		var vx = randf_range(-420.0, 420.0)
		var vy = randf_range(-300.0, 300.0)
		# Garante velocidade mínima
		if abs(vx) < 150.0:
			vx = 220.0 * (1.0 if randf() > 0.5 else -1.0)
		if abs(vy) < 100.0:
			vy = 180.0 * (1.0 if randf() > 0.5 else -1.0)
			
		dice_data[i]["pos"] = Vector2(rx, ry)
		dice_data[i]["vel"] = Vector2(vx, vy)
		dice_data[i]["rot_vel"] = randf_range(-22.0, 22.0)
		dice_data[i]["target_val"] = target_num
		
		_apply_die_style(dice_nodes[i], "rolling")
	
	roll_started.emit()

func _process(delta: float):
	if not is_rolling:
		return
		
	roll_elapsed += delta
	scramble_timer += delta
	
	var tray_w = size.x if size.x > 0 else 520.0
	var tray_h = size.y if size.y > 0 else 200.0
	
	var min_x = tray_padding
	var max_x = tray_w - tray_padding - die_size.x
	var min_y = tray_padding
	var max_y = tray_h - tray_padding - die_size.y - 30.0 # margem para o label de resumo
	
	var should_scramble = false
	if scramble_timer >= 0.045:
		scramble_timer = 0.0
		should_scramble = true
	
	# Simula física 2D de colisão e desaceleração
	for i in range(dice_nodes.size()):
		var d = dice_data[i]
		var node = dice_nodes[i]
		var lbl = dice_labels[i]
		
		# Atualiza movimento
		d["pos"] += d["vel"] * delta
		d["rot"] += d["rot_vel"] * delta
		
		# Desaceleração suave por atrito com o couro
		d["vel"] = d["vel"].move_toward(Vector2.ZERO, 260.0 * delta)
		d["rot_vel"] = move_toward(d["rot_vel"], 0.0, 12.0 * delta)
		
		# Quica nas 4 paredes da bandeja
		if d["pos"].x < min_x:
			d["pos"].x = min_x
			d["vel"].x = abs(d["vel"].x) * 0.78 + randf_range(-30, 30)
			d["rot_vel"] = randf_range(-15, 15)
		elif d["pos"].x > max_x:
			d["pos"].x = max_x
			d["vel"].x = -abs(d["vel"].x) * 0.78 + randf_range(-30, 30)
			d["rot_vel"] = randf_range(-15, 15)
			
		if d["pos"].y < min_y:
			d["pos"].y = min_y
			d["vel"].y = abs(d["vel"].y) * 0.78 + randf_range(-30, 30)
			d["rot_vel"] = randf_range(-15, 15)
		elif d["pos"].y > max_y:
			d["pos"].y = max_y
			d["vel"].y = -abs(d["vel"].y) * 0.78 + randf_range(-30, 30)
			d["rot_vel"] = randf_range(-15, 15)
		
		# Troca o número visual durante o giro
		if should_scramble:
			lbl.text = str((randi() % 10) + 1)
			
		node.position = d["pos"]
		node.rotation = d["rot"]
	
	# Quando o tempo limite expirar, assenta os dados no formato final
	if roll_elapsed >= roll_duration:
		_settle_dice()

func _settle_dice():
	is_rolling = false
	
	var count = dice_nodes.size()
	for i in range(count):
		var node = dice_nodes[i]
		var lbl = dice_labels[i]
		var final_val = dice_data[i]["target_val"]
		var target_grid_pos = _get_grid_position(i, count)
		
		lbl.text = str(final_val)
		
		# Estilo de destaque do Storyteller
		if final_val >= 6:
			_apply_die_style(node, "success")
			lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
		elif final_val == 1:
			_apply_die_style(node, "botch")
			lbl.add_theme_color_override("font_color", Color(1.0, 0.7, 0.7))
		else:
			_apply_die_style(node, "neutral")
			lbl.add_theme_color_override("font_color", Color(0.85, 0.8, 0.75))
		
		# Animação suave para alinhar na grade com pulso de escala
		var tween = create_tween().set_parallel(true)
		tween.tween_property(node, "position", target_grid_pos, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(node, "rotation", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		node.scale = Vector2(1.35, 1.35)
		var scale_tween = create_tween()
		scale_tween.tween_property(node, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Exibe resumo do resultado
	var sucessos = current_result.get("sucessos_brutos", 0)
	var uns = current_result.get("uns_rolados", 0)
	var finais = current_result.get("sucessos_finais", 0)
	
	if summary_label:
		if finais > 0:
			summary_label.text = "🎯 %d Sucessos (≥6)  -  💀 %d Uns (anulam)  =  ★ %d SUCESSO%s FINAIS!" % [
				sucessos, uns, finais, "S" if finais > 1 else ""
			]
		elif sucessos == 0 and uns > 0:
			summary_label.text = "💀 FALHA CRÍTICA! (Nenhum sucesso e %d uns rolados!)" % uns
		else:
			summary_label.text = "❌ FALHA (0 Sucessos Finais) — O salão permanece indecifrável."
			
	roll_completed.emit(current_result)

func _get_grid_position(index: int, total: int) -> Vector2:
	var tray_w = size.x if size.x > 0 else 520.0
	var tray_h = size.y if size.y > 0 else 200.0
	
	# 8 dados: 2 fileiras de 4 dados
	var cols = 4
	var col = index % cols
	var row = index / cols
	
	var col_width = (tray_w - (tray_padding * 2)) / cols
	var row_height = 54.0
	
	var start_x = tray_padding + (col * col_width) + (col_width - die_size.x) / 2.0
	var start_y = tray_padding + 15.0 + (row * (row_height + 8.0))
	
	return Vector2(start_x, start_y)

func _apply_die_style(node: PanelContainer, style_type: String):
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	
	match style_type:
		"success":
			style.bg_color = Color(0.4, 0.28, 0.06, 0.98) # Dourado colonial escuro
			style.border_color = Color(1.0, 0.85, 0.25, 1.0) # Ouro brilhante
			style.shadow_color = Color(1.0, 0.8, 0.1, 0.5)
			style.shadow_size = 6
		"botch":
			style.bg_color = Color(0.35, 0.08, 0.08, 0.98) # Sangue / Carmim escuro
			style.border_color = Color(0.95, 0.25, 0.25, 1.0) # Vermelho alerta
			style.shadow_color = Color(0.8, 0.1, 0.1, 0.4)
			style.shadow_size = 4
		"rolling":
			style.bg_color = Color(0.18, 0.15, 0.12, 0.95)
			style.border_color = Color(0.7, 0.6, 0.45, 1.0)
			style.shadow_color = Color(0, 0, 0, 0.5)
			style.shadow_size = 4
		_: # "neutral"
			style.bg_color = Color(0.12, 0.1, 0.08, 0.96)
			style.border_color = Color(0.55, 0.48, 0.38, 1.0)
			style.shadow_color = Color(0, 0, 0, 0.4)
			style.shadow_size = 3
			
	node.add_theme_stylebox_override("panel", style)
