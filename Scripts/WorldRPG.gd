extends Node2D

@onready var player = $YSortContainer/Player
@onready var chest_sprite = $YSortContainer/TropeiroCamp/Bau/Sprite2D
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

var current_target = null
var chest_opened = false
var amulet_collected = false
var flame_communed = false

func _ready():
	dialogue_box.visible = false
	dice_log_panel.visible = false
	inventory_panel.visible = false
	_update_hud()
	_show_hint("A NOITE DO FOGO & P?LVORA:", "Estouros de trov?o e fogo cercaram sua aldeia. Soldados da Coroa chegaram marchando com armaduras de ferro. Voc? escapou pelas sombras da mata e alcan?ou o alto da Serra da Mantiqueira... Encontre a trilha dos tropeiros e as entidades ancestrais para sobreviver! [Use WASD para andar | E para interagir]")
	# Conex?o das ?reas de intera??o
	$YSortContainer/StartingClearing/CurupiraTotem/Area2D.body_entered.connect(func(b): if b == player: register_target("curupira", "TOTEM ANCESTRAL", "Tronco consagrado ao Curupira. Pressione [E] para interagir."))
	$YSortContainer/StartingClearing/CurupiraTotem/Area2D.body_exited.connect(func(b): if b == player: unregister_target("curupira"))

	$YSortContainer/StartingClearing/Amuleto.body_entered.connect(func(b): if b == player and not amulet_collected: register_target("amulet", "BRILHO NA RELVA", "Um Amuleto de Esmeralda Antigo cintila no ch?o. Pressione [E] para recolher."))
	$YSortContainer/StartingClearing/Amuleto.body_exited.connect(func(b): if b == player: unregister_target("amulet"))

	$YSortContainer/Crossroads/Placa.body_entered.connect(func(b): if b == player: register_target("signpost", "ENCRUZILHADA DA SERRA", "Placa de madeira entalhada. Pressione [E] para ler."))
	$YSortContainer/Crossroads/Placa.body_exited.connect(func(b): if b == player: unregister_target("signpost"))

	$YSortContainer/TropeiroCamp/Cabana/PortaArea.body_entered.connect(func(b): if b == player: register_target("cabin_door", "CABANA DE PAU-A-PIQUE", "Porta trancada por dentro. Pressione [E] para bater."))
	$YSortContainer/TropeiroCamp/Cabana/PortaArea.body_exited.connect(func(b): if b == player: unregister_target("cabin_door"))

	$YSortContainer/TropeiroCamp/Fogueira/Area2D.body_entered.connect(func(b): if b == player: register_target("campfire", "FOGUEIRA TROPEIRA", "Brasas quentes e caldeir?o de caf?. Pressione [E] para descansar e restaurar Vida."))
	$YSortContainer/TropeiroCamp/Fogueira/Area2D.body_exited.connect(func(b): if b == player: unregister_target("campfire"))

	$YSortContainer/TropeiroCamp/Bau.body_entered.connect(func(b): if b == player and not chest_opened: register_target("chest", "BA? DE CARGA", "Ba? de ferro e madeira. Pressione [E] para abrir."))
	$YSortContainer/TropeiroCamp/Bau.body_exited.connect(func(b): if b == player: unregister_target("chest"))

	$YSortContainer/SacredMarsh/AltarFogoFatuo/Area2D.body_entered.connect(func(b): if b == player: register_target("flame_altar", "ALTAR DO FOGO-F?TUO", "Chama azul viva sobre o altar de pedra. Pressione [E] para comunh?o espiritual."))
	$YSortContainer/SacredMarsh/AltarFogoFatuo/Area2D.body_exited.connect(func(b): if b == player: unregister_target("flame_altar"))

	$YSortContainer/SacredMarsh/OssadaSoldado.body_entered.connect(func(b): if b == player: register_target("skeleton", "RESTOS NA LAMA", "Ossada antiga de soldado colonial. Pressione [E] para vasculhar."))
	$YSortContainer/SacredMarsh/OssadaSoldado.body_exited.connect(func(b): if b == player: unregister_target("skeleton"))


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

func _show_hint(speaker: String, text: String):
	speaker_label.text = speaker
	dialogue_label.text = text
	dialogue_box.visible = true

func register_target(target_name: String, hint_speaker: String, hint_text: String):
	current_target = target_name
	_show_hint(hint_speaker, hint_text)

func unregister_target(target_name: String):
	if current_target == target_name:
		current_target = null

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			inventory_panel.visible = !inventory_panel.visible
			_refresh_inventory()
			
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if current_target != null:
				_interact(current_target)
			elif dialogue_box.visible:
				dialogue_box.visible = false

func _interact(target: String):
	var arch = GameManager.current_archetype
	match target:
		"curupira":
			var pool = max(1, arch["misticismo"])
			var roll = DiceRoller.rolar_teste(pool, 6)
			dice_log_panel.visible = true
			dice_log_text.text = "? TESTE DE MISTICISMO (Parada D10: %d) ?\nDados: %s | Sucessos: %d | Resultado: %s" % [
				pool, str(roll["dados_rolados"]), roll["sucessos_finais"], roll["resultado_narrativo"].to_upper()
			]
			if roll["sucessos_finais"] > 0:
				_show_hint("O CURUPIRA (Senhor da Mata):", "'Seus p?s sabem honrar o solo ancestral, %s! Siga ao norte at? a encruzilhada. A oeste h? ferro e p?lvora; a leste, a chama sagrada do brejo.'" % arch["name"])
			else:
				_show_hint("O CURUPIRA (Senhor da Mata):", "'Hihihi! Quem entra sem respeito perde o rumo das pr?prias pegadas!' (Voc? sente uma tontura m?gica nas pernas!)")
				
		"amulet":
			if not amulet_collected:
				amulet_collected = true
				$YSortContainer/StartingClearing/Amuleto/Sprite2D.visible = false
				GameManager.add_item("Amuleto de Esmeralda do Curupira")
				_update_hud()
				_show_hint("AMULETO RECOLHIDO:", "Voc? pega a rel?quia de esmeralda do ch?o! Ela vibra com calor vivo e proteger? seu esp?rito.")
				
		"signpost":
			_show_hint("PLACA DA ENCRUZILHADA:", "? OESTE: Pouso dos Tropeiros & Cabana da Serra\n? LESTE: Brejo do Fogo-F?tuo & Altar Ancestral\n? SUL: Clareira dos Jequitib?s")
			
		"campfire":
			arch["vida_atual"] = min(arch["vida_max"], arch["vida_atual"] + 4)
			_update_hud()
			_show_hint("FOGUEIRA TROPEIRA:", "Voc? se senta junto ?s pedras quentes e bebe um gole de caf? de milho torrado. Recuperou +4 de Vida!")
			
		"chest":
			if not chest_opened:
				chest_opened = true
				chest_sprite.texture = load("res://Assets/Sprites/bau_aberto.png")
				GameManager.add_item("Fac?o de Tr?s Listras (Ferro Forjado)")
				GameManager.add_item("Feij?o Tropeiro da Serra (+6 HP)")
				GameManager.add_item("Carta Secreta da Coroa")
				_update_hud()
				_show_hint("BA? DE CARGA ABERTO:", "Voc? abriu a fechadura de lat?o! Encontrou um Fac?o de Tr?s Listras de ferro pesado, mantimentos de feij?o tropeiro e a correspond?ncia das mil?cias!")
			else:
				_show_hint("BA? DE CARGA:", "O ba? de ferro j? foi saqueado.")
				
		"cabin_door":
			_show_hint("CABANA DE PAU-A-PIQUE:", "Toc-toc... Voc? ouve um gatilho de mosquete sendo armado l? dentro: 'Quem t? rondando meu pouso? Se for capit?o-do-mato, vai provar do meu chumbo!'")
			
		"flame_altar":
			if flame_communed:
				_show_hint("ALTAR DO FOGO-F?TUO:", "A chama azul sussurra em paz, j? unida ao seu esp?rito ancestral.")
				return
			var has_amulet = false
			for item in GameManager.inventory:
				if "Amuleto" in item or "Esmeralda" in item:
					has_amulet = true
					break
			if has_amulet:
				flame_communed = true
				GameManager.add_item("Centelha de Boitat? (Chama Sagrada)")
				arch["mana_atual"] = min(arch["mana_max"], arch["mana_atual"] + 6)
				arch["vida_atual"] = min(arch["vida_max"], arch["vida_atual"] + 3)
				_update_hud()
				_show_hint("HARMONIA DO BOITAT?:", "O Amuleto de Esmeralda ressoa em azul e verde! A labareda do p?ntano envolve seu corpo sem queimar: Mana e Vida restauradas e 'Centelha de Boitat?' obtida!")
			else:
				var pool = max(1, arch["misticismo"])
				var roll = DiceRoller.rolar_teste(pool, 6)
				dice_log_panel.visible = true
				dice_log_text.text = "? TESTE D10 DE MISTICISMO NO BREJO ?\nDados: %s | Sucessos: %d | Resultado: %s" % [
					str(roll["dados_rolados"]), roll["sucessos_finais"], roll["resultado_narrativo"].to_upper()
				]
				flame_communed = true
				if roll["sucessos_finais"] > 0:
					GameManager.add_item("Centelha de Boitat? (Chama Sagrada)")
					arch["mana_atual"] = min(arch["mana_max"], arch["mana_atual"] + 4)
					_update_hud()
					_show_hint("VIT?RIA ESPIRITUAL:", "Sua determina??o dobra o fogo-f?tuo ? sua vontade! Voc? absorve a ess?ncia: +4 Mana e 'Centelha de Boitat?' obtida!")
				else:
					arch["vida_atual"] = max(1, arch["vida_atual"] - 2)
					GameManager.add_item("Frasco de N?voa Fria")
					_update_hud()
					_show_hint("GOLPE G?LIDO:", "O arrepio g?lido da n?voa queima sua carne (-2 Vida)! Voc? aprisiona o vapor num Frasco de N?voa Fria.")
					
		"skeleton":
			GameManager.add_item("B?ssola de Lat?o Colonial")
			GameManager.add_item("Dobr?es Antigos de Prata")
			_update_hud()
			_show_hint("DESPOJOS NA LAMA:", "Entre os ossos do velho soldado bandeirante, voc? resgata uma B?ssola de Lat?o e moedas de prata coloniais!")
