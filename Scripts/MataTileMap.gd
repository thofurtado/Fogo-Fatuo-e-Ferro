extends Node2D

@onready var chao_layer = $ChaoLayer
@onready var objetos_layer = $ObjetosLayer
@onready var copas_layer = $CopasLayer
@onready var player = $Player
@onready var camera = $Player/Camera2D

# HUD & UI
@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_label = $UILayer/DialogueBox/MarginContainer/VBoxContainer/DialogueText
@onready var speaker_label = $UILayer/DialogueBox/MarginContainer/VBoxContainer/Speaker
@onready var dice_log_panel = $UILayer/DiceLogPanel
@onready var dice_log_text = $UILayer/DiceLogPanel/MarginContainer/DiceLogLabel
@onready var inventory_panel = $UILayer/InventoryPanel
@onready var inventory_text = $UILayer/InventoryPanel/MarginContainer/VBoxContainer/ItemListLabel

@onready var hud_hero_name = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HeroLabel
@onready var hud_hp = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/HpLabel
@onready var hud_mana = $UILayer/TopHUD/MarginContainer/VBoxContainer/HBoxContainer/ManaLabel

# Zonas de Intera??o
var active_interactable = null
var chest_opened = false
var amulet_taken = false
var flame_blessed = false

func _ready():
	dialogue_box.visible = false
	dice_log_panel.visible = false
	inventory_panel.visible = false
	
	_build_world_map()
	_setup_interaction_areas()
	_update_hud()
	
	_show_hint("CR?NICA DA MANTIQUEIRA", "Bem-vindo ao mundo vivo de Fogo-F?tuo & Ferro! Use [WASD] ou Setas para andar livremente. Aproxime-se dos objetos e aperte [E] para interagir. [I] abre a mochila.")

func _build_world_map():
	var MAP_SIZE = 40 # 40x40 tiles (1280x1280 pixels)
	
	# 1. Preenchimento de Grama Base com Varia??es
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var tile_type = Vector2i(0, 0) # Grama pura
			var r = (x * 7 + y * 13) % 17
			if r == 1:
				tile_type = Vector2i(1, 0) # Capim alto
			elif r == 2:
				tile_type = Vector2i(2, 0) # Flor silvestre
			elif r == 3:
				tile_type = Vector2i(3, 0) # Pedra na grama
			chao_layer.set_cell(Vector2i(x, y), 0, tile_type)
	
	# 2. Estrada de Terra Batida dos Tropeiros (corta de Sul a Norte, com ramifica??es)
	for y in range(8, MAP_SIZE):
		chao_layer.set_cell(Vector2i(20, y), 0, Vector2i(0, 1))
		chao_layer.set_cell(Vector2i(21, y), 0, Vector2i(0, 1))
	
	# Ramifica??o Oeste (Para o Rancho Tropeiro: Y=18, X de 8 a 20)
	for x in range(8, 20):
		chao_layer.set_cell(Vector2i(x, 18), 0, Vector2i(0, 1))
		chao_layer.set_cell(Vector2i(x, 19), 0, Vector2i(0, 1))
		
	# Ramifica??o Leste (Para o Brejo: Y=18, X de 21 a 32)
	for x in range(21, 33):
		chao_layer.set_cell(Vector2i(x, 18), 0, Vector2i(0, 1))
		chao_layer.set_cell(Vector2i(x, 19), 0, Vector2i(0, 1))

	# 3. O Brejo do Fogo-F?tuo (Nordeste: X de 28 a 38, Y de 6 a 16)
	for x in range(28, 39):
		for y in range(6, 17):
			var water_tile = Vector2i(0, 2) # ?gua escura
			if (x + y) % 5 == 0:
				water_tile = Vector2i(1, 2) # Vit?ria-r?gia
			elif (x == 33 and y == 11):
				water_tile = Vector2i(2, 2) # Reflexo azul do fogo-f?tuo
			chao_layer.set_cell(Vector2i(x, y), 0, water_tile)

	# Pontilh?o de t?buas cruzando o Brejo at? o Altar
	for x in range(29, 34):
		chao_layer.set_cell(Vector2i(x, 11), 0, Vector2i(0, 7))

	# 4. Objetos e Constru??es na Camada Y-Sort
	# Rancho dos Tropeiros (X=9 a 14, Y=12 a 15)
	for x in range(9, 15):
		for y in range(12, 16):
			if y == 12:
				objetos_layer.set_cell(Vector2i(x, y), 0, Vector2i(3, 3)) # Telhado
			elif y == 15 and x == 11:
				objetos_layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 3)) # Porta de madeira
			elif y == 15 and (x == 10 or x == 13):
				objetos_layer.set_cell(Vector2i(x, y), 0, Vector2i(1, 3)) # Janela colonial
			else:
				objetos_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 3)) # Taipa pau-a-pique

	# Cerca de mour?o do rancho
	for x in range(8, 16):
		objetos_layer.set_cell(Vector2i(x, 17), 0, Vector2i(4, 3))
	
	# Fogueira e Ba? de carga junto ao rancho
	objetos_layer.set_cell(Vector2i(12, 18), 0, Vector2i(0, 5)) # Fogueira tropeira
	objetos_layer.set_cell(Vector2i(14, 18), 0, Vector2i(1, 5)) # Ba? com ferro

	# Placa na Encruzilhada (X=20, Y=17)
	objetos_layer.set_cell(Vector2i(20, 17), 0, Vector2i(3, 5))

	# Altar de Pedra e Fogo-F?tuo no Brejo (X=34, Y=11)
	objetos_layer.set_cell(Vector2i(34, 11), 0, Vector2i(1, 6)) # Totem/Altar
	objetos_layer.set_cell(Vector2i(34, 10), 0, Vector2i(0, 6)) # Chama Fogo-F?tuo
	objetos_layer.set_cell(Vector2i(31, 14), 0, Vector2i(2, 6)) # Ossada do bandeirante

	# Floresta de Jequitib?s e Arauc?rias (Troncos com Y-Sort e Copas na camada superior)
	var tree_positions = [
		Vector2i(17, 32), Vector2i(24, 33), Vector2i(15, 27), Vector2i(26, 26),
		Vector2i(18, 22), Vector2i(23, 21), Vector2i(6, 10), Vector2i(16, 9),
		Vector2i(25, 10), Vector2i(27, 4), Vector2i(17, 12), Vector2i(5, 22),
		Vector2i(6, 30), Vector2i(32, 28), Vector2i(35, 22), Vector2i(36, 18)
	]
	for pos in tree_positions:
		# Tronco no ch?o (Y-Sort)
		objetos_layer.set_cell(pos, 0, Vector2i(0, 4))
		# Copa frondosa acima (CopasLayer - jogador passa por baixo)
		copas_layer.set_cell(Vector2i(pos.x, pos.y - 1), 0, Vector2i(1, 4))
		copas_layer.set_cell(Vector2i(pos.x - 1, pos.y - 1), 0, Vector2i(1, 4))
		copas_layer.set_cell(Vector2i(pos.x + 1, pos.y - 1), 0, Vector2i(1, 4))

	# Curupira Totem na Clareira Sul (X=19, Y=34)
	objetos_layer.set_cell(Vector2i(19, 34), 0, Vector2i(1, 6))

func _setup_interaction_areas():
	# Configura n?s de ?rea para checar proximidade do jogador
	_add_trigger("curupira", Vector2(19 * 32 + 16, 34 * 32 + 16), 48.0)
	_add_trigger("amulet", Vector2(22 * 32 + 16, 34 * 32 + 16), 40.0)
	_add_trigger("sign", Vector2(20 * 32 + 16, 17 * 32 + 16), 44.0)
	_add_trigger("fire", Vector2(12 * 32 + 16, 18 * 32 + 16), 45.0)
	_add_trigger("chest", Vector2(14 * 32 + 16, 18 * 32 + 16), 40.0)
	_add_trigger("cabin_door", Vector2(11 * 32 + 16, 15 * 32 + 16), 40.0)
	_add_trigger("fogofatuo", Vector2(34 * 32 + 16, 11 * 32 + 16), 55.0)
	_add_trigger("ossada", Vector2(31 * 32 + 16, 14 * 32 + 16), 42.0)

func _add_trigger(trigger_name: String, pos: Vector2, radius: float):
	var area = Area2D.new()
	area.name = trigger_name
	area.position = pos
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	col.shape = shape
	area.add_child(col)
	add_child(area)
	
	area.body_entered.connect(func(body):
		if body.name == "Player":
			active_interactable = trigger_name
			_on_trigger_hint(trigger_name)
	)
	area.body_exited.connect(func(body):
		if body.name == "Player" and active_interactable == trigger_name:
			active_interactable = null
	)

func _on_trigger_hint(t: String):
	match t:
		"curupira":
			_show_hint("TOTEM DO CURUPIRA", "Tronco ancestral consagrado ao senhor das matas. Pressione [E] para oferenda e teste de Misticismo.")
		"amulet":
			if not amulet_taken:
				_show_hint("BRILHO NA RELVA", "Um Amuleto de Esmeralda Antigo cintila entre as folhas. Pressione [E] para recolher.")
		"sign":
			_show_hint("PLACA DA ENCRUZILHADA", "Pressione [E] para ler as dire??es entalhadas.")
		"fire":
			_show_hint("FOGUEIRA TROPEIRA", "Brasas quentes e caldeir?o de feij?o. Pressione [E] para descansar e restaurar +4 Vida.")
		"chest":
			if not chest_opened:
				_show_hint("BA? DE CARGA", "Ba? de madeira refor?ado com ferro. Pressione [E] para for?ar a tranca.")
		"cabin_door":
			_show_hint("PORTA DO POUSO", "Porta de pau-a-pique trancada por dentro. Pressione [E] para bater.")
		"fogofatuo":
			_show_hint("ALTAR DO FOGO-F?TUO", "Uma labareda azul queima sobre as ?guas negras. Pressione [E] para comunh?o ancestral.")
		"ossada":
			_show_hint("OSSADA NA LAMA", "Restos de um soldado bandeirante. Pressione [E] para vasculhar.")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			inventory_panel.visible = !inventory_panel.visible
			_refresh_inventory()
			
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if active_interactable != null:
				_interact(active_interactable)
			elif dialogue_box.visible:
				dialogue_box.visible = false

func _interact(t: String):
	var arch = GameManager.current_archetype
	match t:
		"curupira":
			var pool = max(1, arch["misticismo"])
			var roll = DiceRoller.rolar_teste(pool, 6)
			dice_log_panel.visible = true
			dice_log_text.text = "? TESTE D10 MISTICISMO (Parada: %d) ?\nDados: %s | Sucessos: %d | Resultado: %s" % [
				pool, str(roll["dados_rolados"]), roll["sucessos_finais"], roll["resultado_narrativo"].to_upper()
			]
			if roll["sucessos_finais"] > 0:
				_show_hint("O CURUPIRA:", "'Seus p?s sabem respeitar o ch?o da floresta, %s! V? em paz pelo caminho do ferro ou da chama!'" % arch["name"])
			else:
				_show_hint("O CURUPIRA:", "'Hihihi! As ?rvores trocam de lugar diante dos olhos dos desavisados!' (Voc? sente uma tontura na trilha!)")
		"amulet":
			if not amulet_taken:
				amulet_taken = true
				GameManager.add_item("Amuleto de Esmeralda do Curupira")
				_update_hud()
				_show_hint("AMULETO RECOLHIDO:", "Voc? pegou o Amuleto de Esmeralda! Ele pulsa suavemente e protege seu esp?rito nas ?guas.")
		"sign":
			_show_hint("PLACA ENTALHADA:", "? OESTE: Pouso e Rancho dos Tropeiros\n? LESTE: Brejo do Fogo-F?tuo e Altar\n? SUL: Clareira dos Jequitib?s")
		"fire":
			arch["vida_atual"] = min(arch["vida_max"], arch["vida_atual"] + 4)
			_update_hud()
			_show_hint("DESCANSO:", "Voc? se aquece nas brasas da fogueira e bebe um gole de caf? de milho torrado. Recuperou +4 de Vida!")
		"chest":
			if not chest_opened:
				chest_opened = true
				GameManager.add_item("Fac?o de Tr?s Listras (Ferro Forjado)")
				GameManager.add_item("Feij?o Tropeiro da Serra (+6 HP)")
				GameManager.add_item("Carta Secreta da Coroa")
				objetos_layer.set_cell(Vector2i(14, 18), 0, Vector2i(2, 5)) # Muda para ba? aberto!
				_update_hud()
				_show_hint("BA? ABERTO:", "Voc? encontrou um Fac?o de Tr?s Listras, por??o de Feij?o Tropeiro e uma Carta com o mapa de patrulha das mil?cias!")
		"cabin_door":
			_show_hint("VOZ DE DENTRO:", "Toc-toc... 'Quem t? no terreiro? Se for capit?o-do-mato ou feitor, vai levar carga de chumbo grosso!'")
		"fogofatuo":
			if flame_blessed:
				_show_hint("FOGO-F?TUO:", "A chama azul queima serena, j? entrela?ada com a sua centelha ancestral.")
				return
			var has_amulet = false
			for item in GameManager.inventory:
				if "Amuleto" in item or "Esmeralda" in item:
					has_amulet = true
					break
			if has_amulet:
				flame_blessed = true
				GameManager.add_item("Centelha de Boitat? (Chama Sagrada)")
				arch["mana_atual"] = min(arch["mana_max"], arch["mana_atual"] + 6)
				arch["vida_atual"] = min(arch["vida_max"], arch["vida_atual"] + 3)
				_update_hud()
				_show_hint("HARMONIA ESPIRITUAL:", "O Amuleto de Esmeralda brilha em resson?ncia com a ?gua! As labaredas azuis envolvem seu her?i com calor m?stico: Vida e Mana restauradas e Centelha de Boitat? obtida!")
			else:
				var pool = max(1, arch["misticismo"])
				var roll = DiceRoller.rolar_teste(pool, 6)
				dice_log_panel.visible = true
				dice_log_text.text = "? TESTE D10 MISTICISMO NO BREJO ?\nDados: %s | Sucessos: %d | %s" % [
					str(roll["dados_rolados"]), roll["sucessos_finais"], roll["resultado_narrativo"].to_upper()
				]
				flame_blessed = true
				if roll["sucessos_finais"] > 0:
					GameManager.add_item("Centelha de Boitat? (Chama Sagrada)")
					arch["mana_atual"] = min(arch["mana_max"], arch["mana_atual"] + 4)
					_update_hud()
					_show_hint("SUCESSO:", "Sua mente domina o vapor do brejo! A chama reconhece sua for?a: +4 Mana e Centelha de Boitat? obtida!")
				else:
					arch["vida_atual"] = max(1, arch["vida_atual"] - 2)
					GameManager.add_item("Frasco de N?voa Fria")
					_update_hud()
					_show_hint("GOLPE G?LIDO:", "O arrepio g?lido da n?voa queima sua alma (-2 Vida)! Voc? retira a m?o com um Frasco de N?voa Fria.")
		"ossada":
			GameManager.add_item("B?ssola de Lat?o Colonial")
			GameManager.add_item("Dobr?es Antigos de Prata")
			_update_hud()
			_show_hint("DESPOJOS:", "Voc? desenterra da lama uma velha B?ssola de Lat?o e moedas coloniais de prata!")

func _show_hint(speaker: String, text: String):
	speaker_label.text = speaker
	dialogue_label.text = text
	dialogue_box.visible = true

func _update_hud():
	var arch = GameManager.current_archetype
	hud_hero_name.text = arch["name"]
	hud_hp.text = "? HP: %d/%d" % [arch["vida_atual"], arch["vida_max"]]
	hud_mana.text = "? MANA: %d/%d" % [arch["mana_atual"], arch["mana_max"]]
	_refresh_inventory()

func _refresh_inventory():
	var text = "ITENS NA MOCHILA:\n"
	for item in GameManager.inventory:
		text += "? " + item + "\n"
	inventory_text.text = text
