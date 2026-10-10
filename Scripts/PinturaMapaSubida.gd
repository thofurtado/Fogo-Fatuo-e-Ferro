@tool
extends Node2D

@export_category("Ferramentas de Pintura de Mapa")
@export var preencher_fundo_com_grama: bool = false:
	set(val):
		if val:
			_preencher_tudo_grama()

@export var limpar_tudo: bool = false:
	set(val):
		if val:
			_limpar_mapa()

@export_range(0.0, 1.0) var opacidade_gabarito: float = 0.45:
	set(val):
		opacidade_gabarito = val
		if has_node("GabaritoReferencia"):
			$GabaritoReferencia.modulate.a = val

@export_group("Enquadramento do Gabarito de Fundo")
@export_range(0.2, 4.0, 0.05) var escala_horizontal_gabarito: float = 1.0:
	set(val):
		escala_horizontal_gabarito = val
		if has_node("GabaritoReferencia"):
			$GabaritoReferencia.scale.x = val

@export_range(0.2, 4.0, 0.05) var escala_vertical_gabarito: float = 1.0:
	set(val):
		escala_vertical_gabarito = val
		if has_node("GabaritoReferencia"):
			$GabaritoReferencia.scale.y = val

@export var deslocamento_gabarito: Vector2 = Vector2.ZERO:
	set(val):
		deslocamento_gabarito = val
		if has_node("GabaritoReferencia"):
			$GabaritoReferencia.position = val

@export_group("Réguas e Moldura de Jogo (1920x2048)")
@export var mostrar_reguas: bool = true:
	set(val):
		mostrar_reguas = val
		if has_node("MolduraGuias"):
			$MolduraGuias.visible = val

@onready var chao_layer: TileMapLayer = $ChaoTileMap

func _ready():
	if not Engine.is_editor_hint():
		# No modo teste, inicia o Tropeiro no GameManager
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.has_method("select_archetype_by_id"):
			gm.select_archetype_by_id("tropeiro")
		# No jogo rodando, começa com o gabarito semitransparente como guia (pressione G para ligar/desligar)
		if has_node("GabaritoReferencia"):
			$GabaritoReferencia.visible = true
			$GabaritoReferencia.modulate.a = 0.35
		if has_node("MolduraGuias"):
			$MolduraGuias.visible = false
		_gerar_escarpas_unidirecionais()
		_gerar_zonas_de_agua_dos_tiles()

func _gerar_zonas_de_agua_dos_tiles():
	var water_scene = preload("res://Scenes/ZonaDeAgua.tscn")
	var water_container = Node2D.new()
	water_container.name = "AutoZonasAguaContainer"
	add_child(water_container)
	
	for layer_name in ["ChaoTileMap", "EscarpasTileMap", "ObjetosTileMap", "AguaTileMap"]:
		var layer = get_node_or_null(layer_name) as TileMapLayer
		if not layer:
			continue
		var all_cells = layer.get_used_cells()
		var water_cells = []
		for c in all_cells:
			if layer.get_cell_atlas_coords(c) == Vector2i(2, 0):
				water_cells.append(c)
				
		if water_cells.is_empty():
			continue
			
		var row_groups = {}
		for c in water_cells:
			if not row_groups.has(c.y):
				row_groups[c.y] = []
			row_groups[c.y].append(c.x)
			
		for y in row_groups.keys():
			var xs = row_groups[y]
			xs.sort()
			var start_x = xs[0]
			var prev_x = xs[0]
			for i in range(1, xs.size()):
				if xs[i] == prev_x + 1:
					prev_x = xs[i]
				else:
					_instanciar_zona_agua_tile(start_x, prev_x, y, layer, water_scene, water_container)
					start_x = xs[i]
					prev_x = xs[i]
			_instanciar_zona_agua_tile(start_x, prev_x, y, layer, water_scene, water_container)
		print("✦ Zonas de Água/Lama ativadas: %d blocos em %s configurados com física de travessia lenta!" % [water_cells.size(), layer_name])

func _instanciar_zona_agua_tile(start_x: int, end_x: int, y: int, layer: TileMapLayer, water_scene: PackedScene, container: Node2D):
	var water = water_scene.instantiate() as ZonaDeAgua
	var count = end_x - start_x + 1
	var width = count * 32.0
	var height = 32.0
	
	var center_x = layer.position.x + (start_x * 32.0) + (width / 2.0)
	var center_y = layer.position.y + (y * 32.0) + 16.0
	
	water.position = Vector2(center_x, center_y)
	water.fator_velocidade = 0.35
	water.afundar_pes_px = 3.5
	water.mostrar_visual_agua = false
	container.add_child(water)
	water.tamanho = Vector2(width, height)

func _gerar_escarpas_unidirecionais():
	var ledge_scene = preload("res://Scenes/EscarpmentLedge.tscn")
	var ledges_container = Node2D.new()
	ledges_container.name = "AutoLedgesContainer"
	add_child(ledges_container)
	
	for layer_name in ["EscarpasTileMap", "ChaoTileMap"]:
		var layer = get_node_or_null(layer_name) as TileMapLayer
		if not layer:
			continue
		var all_cells = layer.get_used_cells()
		var raw_cells = []
		var cell_set = {}
		for c in all_cells:
			if layer.get_cell_atlas_coords(c) == Vector2i(5, 0):
				raw_cells.append(c)
				cell_set[c] = true
				
		if raw_cells.is_empty():
			continue

		# 1. Filtra APENAS células que são o TOPO de uma escarpa
		# (ou seja, células que NÃO têm outro bloco (5,0) logo acima em y - 1)
		var top_cells = []
		for c in raw_cells:
			if not cell_set.has(Vector2i(c.x, c.y - 1)):
				top_cells.append(c)

		# Ordena por Y (de cima para baixo) e depois por X (da esquerda para direita)
		top_cells.sort_custom(func(a, b):
			if a.y != b.y: return a.y < b.y
			return a.x < b.x
		)

		# 2. Para cada célula de topo, calcula a profundidade vertical da coluna
		var column_info = {}
		for c in top_cells:
			var h = 1
			while cell_set.has(Vector2i(c.x, c.y + h)):
				h += 1
			column_info[c] = h

		# 3. Agrupa células vizinhas no mesmo Y que tenham a mesma altura de queda
		var processed = {}
		for c in top_cells:
			if processed.has(c):
				continue
			var h = column_info[c]
			var start_x = c.x
			var end_x = c.x
			while cell_set.has(Vector2i(end_x + 1, c.y)) and not cell_set.has(Vector2i(end_x + 1, c.y - 1)) and column_info.get(Vector2i(end_x + 1, c.y), 0) == h:
				end_x += 1
				
			for x in range(start_x, end_x + 1):
				processed[Vector2i(x, c.y)] = true
				
			_criar_ledge_instancia(start_x, end_x, c.y, h, layer, ledge_scene, ledges_container)

func _criar_ledge_instancia(start_x: int, end_x: int, y: int, height: int, layer: TileMapLayer, ledge_scene: PackedScene, container: Node2D):
	var ledge = ledge_scene.instantiate() as EscarpmentLedge
	var count = end_x - start_x + 1
	var width = count * 32.0
	var height_px = height * 32.0
	
	var center_x = layer.position.x + (start_x * 32.0) + (width / 2.0)
	var center_y = layer.position.y + (y * 32.0) + 16.0
	
	ledge.position = Vector2(center_x, center_y)
	ledge.ledge_width = width
	ledge.ledge_height = height_px
	ledge.drop_distance = height_px + 14.0 # 1 bloco: 46px; 2 blocos: 78px
	ledge.penalty_hp = 3 if height == 1 else 6 # Maior altura = maior risco/impacto
	
	if ledge.has_node("NinePatchRect"):
		ledge.get_node("NinePatchRect").visible = false
		
	container.add_child(ledge)
	print("✦ Escarpa Unidirecional ativada: Linha Y=%d (Altura: %d blocos / %d px), Colunas %d a %d (Largura: %d px)" % [
		y, height, int(height_px), start_x, end_x, int(width)
	])

func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_G:
				if has_node("GabaritoReferencia"):
					$GabaritoReferencia.visible = not $GabaritoReferencia.visible
					print("Gabarito visibilidade: ", $GabaritoReferencia.visible)
			elif event.keycode == KEY_H:
				if has_node("MolduraGuias"):
					$MolduraGuias.visible = not $MolduraGuias.visible
					print("Réguas e Moldura visibilidade: ", $MolduraGuias.visible)


func _preencher_tudo_grama():
	var layer = $ChaoTileMap as TileMapLayer
	if not layer:
		return
	print("Preenchendo 60 x 64 blocos com Grama Verde...")
	# 60 colunas x 64 linhas (3 telas x 2 telas na resolução 20x32)
	for x in range(60):
		for y in range(64):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	print("Pronto! Fundo verde completo. Agora escolha o pincel de Barro, Água ou Escarpa e pinte à vontade!")

func _limpar_mapa():
	for layer_name in ["ChaoTileMap", "EscarpasTileMap", "ObjetosTileMap"]:
		var layer = get_node_or_null(layer_name) as TileMapLayer
		if layer:
			layer.clear()
			layer.position = Vector2.ZERO
	print("✦ Todas as camadas de pintura foram limpas e alinhadas em (0, 0)! Tela 100% nova.")
