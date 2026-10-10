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
		_gerar_escarpas_unidirecionais()

func _gerar_escarpas_unidirecionais():
	var ledge_scene = preload("res://Scenes/EscarpmentLedge.tscn")
	var ledges_container = Node2D.new()
	ledges_container.name = "AutoLedgesContainer"
	add_child(ledges_container)
	
	for layer_name in ["EscarpasTileMap", "ChaoTileMap"]:
		var layer = get_node_or_null(layer_name) as TileMapLayer
		if not layer:
			continue
		var cells = layer.get_used_cells()
		var rows = {}
		for c in cells:
			if layer.get_cell_atlas_coords(c) == Vector2i(5, 0):
				if not rows.has(c.y):
					rows[c.y] = []
				rows[c.y].append(c.x)
		
		for y in rows.keys():
			var xs = rows[y]
			xs.sort()
			var start_x = xs[0]
			var prev_x = xs[0]
			for i in range(1, xs.size()):
				var x = xs[i]
				if x == prev_x + 1:
					prev_x = x
				else:
					_criar_ledge_instancia(start_x, prev_x, y, layer, ledge_scene, ledges_container)
					start_x = x
					prev_x = x
			_criar_ledge_instancia(start_x, prev_x, y, layer, ledge_scene, ledges_container)

func _criar_ledge_instancia(start_x: int, end_x: int, y: int, layer: TileMapLayer, ledge_scene: PackedScene, container: Node2D):
	var ledge = ledge_scene.instantiate() as EscarpmentLedge
	var count = end_x - start_x + 1
	var width = count * 32.0
	var center_x = layer.position.x + (start_x * 32.0) + (width / 2.0)
	var center_y = layer.position.y + (y * 32.0) + 16.0
	ledge.position = Vector2(center_x, center_y)
	ledge.ledge_width = width
	if ledge.has_node("NinePatchRect"):
		ledge.get_node("NinePatchRect").visible = false
	container.add_child(ledge)
	print("✦ Escarpa Unidirecional ativada: Linha Y=%d, Colunas %d a %d (Largura: %d px)" % [y, start_x, end_x, int(width)])

func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_G:
				if has_node("GabaritoReferencia"):
					$GabaritoReferencia.visible = not $GabaritoReferencia.visible
					print("Gabarito visibilidade: ", $GabaritoReferencia.visible)


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
	var layer = $ChaoTileMap as TileMapLayer
	if layer:
		layer.clear()
		print("Mapa limpo!")
